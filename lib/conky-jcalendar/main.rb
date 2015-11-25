require 'yaml'

module ConkyJCalendar

  CONFIG_FILE_DEFAULT = '../../../config/conky-jcalendar.yaml'
  CONFIG_FILE_USER    = "#{ENV['HOME']}/.config/conky-jcalendar.yaml"
  CONFIG_FILE_COMPAT  = "#{ENV['HOME']}/.config/conky-jcalendar.yml"

  class Main

    def initialize(options)
      @options = options
      set_config_default(CONFIG_FILE_DEFAULT)
      set_config_user(CONFIG_FILE_USER)
    end

    def set_config_default(default_file)
      filename = File.expand_path(default_file, __FILE__)
      @config = YAML.load_file(filename)
    end

    def set_config_user(user_file)
      user = YAML.load_file(user_file)
      @config['calendar'].merge!(user['calendar']) if user['calendar']
      @config['event'].merge!(user['event']) if user['event']
      @config['style'].merge!(user['style']) if user['style']
    rescue Errno::ENOENT
      unless user_file == CONFIG_FILE_COMPAT
        set_config_user(CONFIG_FILE_COMPAT)
      end
    end

    def all
      calendar
      event
    end

    def calendar(debug = false)
      Calendar.new(@options, @config, debug).generate
    end

    def event(debug = false)
      Event.new(@options, @config, debug).show
    end

    def debug
      pp @options
      pp @config
      calendar(true)
      event(true)
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

