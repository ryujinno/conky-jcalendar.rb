require 'date'
require 'ri_cal'
require 'pp'

require 'conky-pim/decorate'

module ConkyPIM
  class Event
    include Decorate

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

      @max_length = options[:length]
    end

    def show
      events   = {}
      holidays = []

      @uri_ics.each do |uri, ics_io|
        if @debug
          pp uri
        end
        if @config['calendar']['holiday_uris'].include?(uri)
          set_weekly_events(ics_io, events, holidays)
        else
          set_weekly_events(ics_io, events)
        end
      end

      putout(events, holidays)
    end

    def set_weekly_events(ics_io, events, holidays = false)
      ics_io.rewind
      cals = RiCal.parse(ics_io)

      this_week = @today.upto(@today + @config['event']['span'] - 1)

      this_week.each do |date|
        events[date] ||= []
        the_day  = date.to_time.localtime
        tomorrow = (date + 1).to_time.localtime

        cals.each do |calendar|
          calendar.events.each do |e|
            e.occurrences(overlapping: [ the_day, tomorrow ]).each do |occur|
              start  = occur.dtstart.to_time.localtime
              finish = occur.dtend.to_time.localtime
              # FIXME: RiCal returns outbound occurrences
              # even if specified with overlapping parameter.
              # Maybe a bug.
              # This condition is workarround.
              if (the_day <= start   && start    < tomorrow ) ||
                 (the_day <  finish  && finish   < tomorrow ) ||
                 (start   <  the_day && tomorrow <= finish)
                events[date] << {
                  start:   start,
                  finish:  finish,
                  summary: occur.summary,
                }
                if holidays
                  holidays << date
                end
              end
            end
          end
        end
        events[date].sort_by! { |e| e[:start] }
      end
    end

    def putout(events, holidays)
      if @debug
        pp events
        pp holidays
      end

      puts(decorate_header('EVENT'))

      events.each do |date, scheds|
        next if scheds.empty?

        str_day = date.to_s
        str_day = decorate_day(str_day, date, @today, holidays)

        puts(str_day)

        scheds.each do |event|
          if event[:start].to_date == date
            start_time = event[:start].strftime(TIME_FORMAT)
          else
            start_time = '**:**'
          end
          if event[:finish].to_date == date
            finish_time = event[:finish].strftime(TIME_FORMAT)
          else
            finish_time = '**:**'
          end

          puts("  #{start_time} - #{finish_time}")
          puts("    #{event[:summary][0, @max_length]}")
        end
      end
    end

  end
end
