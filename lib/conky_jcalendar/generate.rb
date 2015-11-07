require 'yaml'
require 'date'
require 'open-uri'
require 'json'
require 'pp'

module ConkyJCalendar

  URL_GOOGLE_CALENDAR = 'http://www.google.com/calendar/feeds/%s/public/basic?alt=json&start-min=%s&start-max=%s&max-results=%s'
  MAX_SCHEDULES = 256

  CONFIG_FILE_DEFAULT = '../../../config/conky_jcalendar.yaml'
  CONFIG_FILE_USER    = "#{ENV['HOME']}/.config/conky_jcalendar.yaml"
  CONFIG_FILE_COMPAT  = "#{ENV['HOME']}/.config/conky_jcalendar.yml"

  class Generate

    def initialize(options)
      @debug = false
      set_config_default(CONFIG_FILE_DEFAULT)
      set_config_user(CONFIG_FILE_USER)
      set_option(options)
      set_monthly_info(options[:today])
    end

    def set_config_default(default_file)
      filename = File.expand_path(default_file, __FILE__)
      config = YAML.load_file(filename)
      @option = config['option']
      @style  = config['style']
    end

    def set_config_user(user_file)
      user = YAML.load_file(user_file)
      @option.merge!(user['option']) if user['option']
      @style.merge!(user['style'])   if user['style']
    rescue Errno::ENOENT
      unless user_file == CONFIG_FILE_COMPAT
        set_config_user(CONFIG_FILE_COMPAT)
      end
    end

    def set_option(options)
      @option['holiday_id']    = options[:holiday_id]    unless options[:holiday_id].nil?
      @option['first_weekday'] = options[:first_weekday] unless options[:first_weekday].nil?
    end

    def set_monthly_info(today)
      @first_weekday ||= Date::DAYNAMES.index(@option['first_weekday'])
      @first_weekday ||= Date::ABBR_DAYNAMES.index(@option['first_weekday'])
      @first_weekday ||= 0  # Fail safe for Sunday

      if today.nil?
        @today = Date.today
      else
        @today = Date.parse(today)
      end

      @first_day = @today.start_of_month
      @last_day  = @today.end_of_month
    end

    def putout
      holidays = get_monthly_holiday
      compose_monthly(holidays)
    end

    alias :conky :putout

    def debug
      @debug = true
      pp @option, @style
      putout
    end

    def get_monthly_holiday
      holidays = []

      return holidays unless @option['holiday_id']

      uri = URL_GOOGLE_CALENDAR % [
        @option['holiday_id'],
        @first_day.to_json,
        @last_day.to_json,
        MAX_SCHEDULES
      ]

      begin
        gcal = open(uri) { |io| JSON.parse(io.read) }

        gcal['feed']['entry'].each do |entry|
          if @debug
            pp entry['content']['$t']
          end
          match = entry['content']['$t'].match(/\d+\/\d+\/\d+/)
          holidays << Date.parse(match[0])
        end
      rescue
      ensure
        return holidays
      end
    end

    def compose_monthly(holidays)
      # Returns a positive value
      last_weekend = (@first_weekday - 1) % 7

      # Header
      month = "#{@today.year} #{Date::MONTHNAMES[@today.month]}"
      cal = decorate_header(month)
      cal += "\n" 

      # Previous month
      #   Returns a positive value
      prev_month_days = (@first_day.wday - @first_weekday) % 7
      prev_month_days.times do
        cal += '   '
      end

      day = @first_day
      while day <= @last_day do
        str_day = '%2d' % day.day

        if day == @today
          str_day = decorate_today(str_day)
        elsif holidays.include?(day)
          str_day = decorate_holiday(str_day)
        elsif day.wday == 6
          str_day = decorate_saturday(str_day)
        elsif day.wday == 0
          str_day = decorate_sunday(str_day)
        end

        # Append date
        if day.wday == last_weekend
          cal += "#{str_day}\n"
        else
          cal += "#{str_day} "
        end

        day += 1
      end

      cal.strip!
      cal += decorate_footer()

      # Show calendar
      puts cal
    end

    def decorate_header(str_month)
      if @debug
        str_month
      else
        "${voffset #{@style['voffset']}}${color #{@style['color_header']}}${font #{@style['font_header']}}#{str_month}${font}${color} ${stippled_hr}${font #{@style['font_day']}}"
      end
    end

    def decorate_today(str_day)
      if @debug
        'To'
      else
        "${font #{@style['font_today']}}${color #{@style['color_today']}}#{str_day}${color}${font}${font #{@style['font_day']}}"
      end
    end

    def decorate_holiday(str_day)
      if @debug
        'Ho'
      else
        "${color #{@style['color_holiday']}}#{str_day}${color}"
      end
    end

    def decorate_saturday(str_day)
      if @debug
        'Sa'
      else
        "${color #{@style['color_saturday']}}#{str_day}${color}"
      end
    end

    def decorate_sunday(str_day)
      if @debug
        'Su'
      else
        "${color #{@style['color_sunday']}}#{str_day}${color}"
      end
    end

    def decorate_footer
      if @debug
        ''
      else
        '${font}'
      end
    end

  end

end

class Date
  def start_of_month
    return self - self.day + 1
  end

  def end_of_month
    next_month = start_of_month + 31
    return next_month - next_month.day
  end

  def to_json
    # 2015-08-01T00:37:44.957Z
    # Google calendar Japanese holiday starts/ends in UTC
    time = to_time
    time += time.utc_offset
    time.strftime('%Y-%m-%dT%T.%LZ')
  end
end
