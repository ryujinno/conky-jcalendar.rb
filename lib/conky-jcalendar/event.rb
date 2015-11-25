require 'date'
require 'open-uri'
require 'ri_cal'
require 'pp'

module ConkyJCalendar
  class Event
    TIME_FORMAT = '%H:%M'

    def initialize(options, config, debug)
      @config = config
      @debug  = debug

      if options[:today].nil?
        @today = Date.today
      else
        @today = Date.parse(options[:today])
      end

      @events = {}
    end

    def show
      @config['event']['calendar_uris'].each do |uri|
        set_weekly_events(uri)
      end

      putout_events
    end

    def set_weekly_events(uri)
      cals = open(uri) { |io| ::RiCal.parse(io) }

      this_week  = @today.upto(@today + 7)

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
