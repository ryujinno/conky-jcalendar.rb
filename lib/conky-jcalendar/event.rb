require 'date'
require 'ri_cal'
require 'pp'

module ConkyJCalendar
  class Event
    EVENT_DAYS  = 7
    TIME_FORMAT = '%H:%M'

    def initialize(options, config, uri_ics, debug = false)
      @config  = config
      @uri_ics = uri_ics
      @debug   = debug

      if options[:today].nil?
        @today = Date.today
      else
        @today = Date.parse(options[:today])
      end

      @events = {}
    end

    def show
      @uri_ics.each do |uri, ics_io|
        if @debug
          pp uri
        end
        set_weekly_events(ics_io)
      end

      putout_events
    end

    def set_weekly_events(ics_io)
      ics_io.rewind
      cals = RiCal.parse(ics_io)

      this_week = @today.upto(@today + EVENT_DAYS - 1)

      this_week.each do |date|
        @events[date] ||= []
        the_day  = date.to_time.localtime
        tommorow = (date + 1).to_time.localtime

        cals.each do |calendar|
          calendar.events.each do |e|
            e.occurrences(overlapping: [the_day, tommorow]).each do |occur|
              start  = occur.dtstart.to_time.localtime
              finish = occur.dtend.to_time.localtime
              # FIXME: RiCal returns outbound occurrences
              # even if specified with overlapping parameter.
              # Maybe a bug.
              # This condition is workarround.
              if (the_day <= start   && start    < tommorow ) ||
                 (the_day <  finish  && finish   < tommorow ) ||
                 (start   <  the_day && tommorow <= finish)
                @events[date] << {
                  start:   start,
                  finish:  finish,
                  summary: occur.summary,
                }
              end
            end
          end
        end
        @events[date].sort_by! { |e| e[:start] }
      end
    end

    def putout_events
      if @debug
        pp @events
      end

      @events.each do |date, scheds|
        next if scheds.empty?

        puts(date)

        scheds.each do |event|
          if event[:start].to_date == date
            start_time = event[:start].strftime(TIME_FORMAT)
          else
            start_time = '*:*'
          end
          if event[:finish].to_date == date
            finish_time = event[:finish].strftime(TIME_FORMAT)
          else
            finish_time = '*:*'
          end

          puts("  #{start_time} - #{finish_time}")
          puts("    #{event[:summary]}")
        end

      end
    end

  end
end
