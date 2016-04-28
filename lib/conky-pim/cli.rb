require 'thor'

module ConkyPIM
  class CLI < Thor
    class_option :pad,    aliases: '-p', type: :numeric, default: 1,  desc: 'Padding of calendar'
    class_option :margin, aliases: '-m', type: :numeric, default: 0,  desc: 'Left margin of calendar'
    class_option :length, aliases: '-l', type: :numeric, default: 16, desc: 'Max length of event summary'
    class_option :today,  aliases: '-t', type: :string,               desc: 'Today of calendar for debugging'

    desc :all, 'Putout calendar and event'

    def all
      Main.new(options).all
    end

    desc :calendar, 'Putout calendar'

    def calendar
      Main.new(options).calendar
    end

    desc :event, 'Putout event'

    def event
      Main.new(options).event
    end

    desc :debug, 'Putout calendar and event for debugging'

    def debug
      Main.new(options).debug
    end
  end
end
