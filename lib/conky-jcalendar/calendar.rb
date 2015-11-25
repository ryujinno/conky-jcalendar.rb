require 'date'
require 'ri_cal'
require 'pp'

module ConkyJCalendar

  class Calendar

    def initialize(options, config, uri_ics, debug = false)
      @config  = config
      @uri_ics = uri_ics
      @debug   = debug
      set_monthly_info(options[:today])
    end

    def set_monthly_info(today)
      @first_weekday ||= Date::DAYNAMES.index(@config['calendar']['first_weekday'])
      @first_weekday ||= Date::ABBR_DAYNAMES.index(@config['calendar']['first_weekday'])
      @first_weekday ||= 0  # Fail safe for Sunday

      if today.nil?
        @today = Date.today
      else
        @today = Date.parse(today)
      end

      @first_day = @today.start_of_month
      @last_day  = @today.end_of_month
    end

    def generate
      holidays = []

      @config['calendar']['holiday_uris'].each do |uri|
        if @debug
          pp uri
        end
        ics_io = @uri_ics[uri]
        holidays += get_monthly_holiday(ics_io)
      end
      compose_calendar(holidays)
    end

    def get_monthly_holiday(ics_io)
      holidays = []

      ics_io.rewind
      cals = RiCal.parse(ics_io)

      cals.each do |calendar|
        calendar.events.each do |e|
          e.occurrences(overlapping: [ @first_day, @last_day ]).each do |occur|
            holidays << occur.dtstart
          end
        end
      end
      
      holidays
    end

    def compose_calendar(holidays)
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
        "${voffset #{@config['style']['voffset']}}${color #{@config['style']['color_header']}}${font #{@config['style']['font_header']}}#{str_month}${font}${color} ${stippled_hr}${font #{@config['style']['font_day']}}"
      end
    end

    def decorate_today(str_day)
      if @debug
        'To'
      else
        "${font #{@config['style']['font_today']}}${color #{@config['style']['color_today']}}#{str_day}${color}${font}${font #{@config['style']['font_day']}}"
      end
    end

    def decorate_holiday(str_day)
      if @debug
        'Ho'
      else
        "${color #{@config['style']['color_holiday']}}#{str_day}${color}"
      end
    end

    def decorate_saturday(str_day)
      if @debug
        'Sa'
      else
        "${color #{@config['style']['color_saturday']}}#{str_day}${color}"
      end
    end

    def decorate_sunday(str_day)
      if @debug
        'Su'
      else
        "${color #{@config['style']['color_sunday']}}#{str_day}${color}"
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
