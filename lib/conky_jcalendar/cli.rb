require 'thor'

module ConkyJCalendar
  class CLI < Thor
    class_option :holiday_id,    aliases: '-h', type: :string, desc: 'Holiday ID of Google Calendar'
    class_option :first_weekday, aliases: '-f', type: :string, desc: 'First day of week for calendar'
    class_option :today, aliases: '-t', type: :string, desc: 'Today of calendar for debugging'

    desc :conky, 'Putout calendar for conky'

    def conky
      Generate.new(options).conky
    end

    desc :debug, 'Putout calendar for debugging'

    def debug
      Generate.new(options).debug
    end
  end
end
