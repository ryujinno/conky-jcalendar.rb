require 'date'
require 'ri_cal'
require 'pp'

require 'conky-pim/decorate'

module ConkyPIM

  class Calendar
    include Decorate

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
        set_monthly_holiday(ics_io, holidays)
      end
      if @debug
        pp holidays
      end
      compose_calendar(holidays)
    end

    def set_monthly_holiday(ics_io, holidays)
      ics_io.rewind
      cals = RiCal.parse(ics_io)

      cals.each do |calendar|
        calendar.events.each do |e|
          e.occurrences(overlapping: [ @first_day, @last_day ]).each do |occur|
            holidays << occur.dtstart.to_date
          end
        end
      end
    end

    def compose_calendar(holidays)
      # Returns a positive value
      last_weekend = (@first_weekday - 1) % 7

      # Header
      month = "#{@today.year} #{@today.strftime('%B')}"
      cal = decorate_header(month)
      cal += "\n"

      # Previous month
      #   Returns a positive value
      prev_month_days = (@first_day.wday - @first_weekday) % 7
      prev_month_days.times do
        if @debug
          cal += '       '
        else
          cal += '   '
        end
      end

      date = @first_day
      while date <= @last_day do
        str_day = '%2d' % date.day
        str_day = decorate_day(str_day, date, @today, holidays)

        # Append date
        if date.wday == last_weekend
          cal += "#{str_day}\n"
        else
          cal += "#{str_day} "
        end

        date += 1
      end

      cal.strip!
      cal += decorate_footer()

      # Show calendar
      puts cal
    end

  end

end
