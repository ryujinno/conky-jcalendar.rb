require 'yaml'
require 'tempfile'
require 'open-uri'

require 'conky-pim/calendar'
require 'conky-pim/event'

module ConkyPIM

  CONFIG_FILE_DEFAULT = '../../../config/conky-pim.yaml'
  CONFIG_FILE_USER    = "#{ENV['HOME']}/.config/conky/pim.yaml"
  CONFIG_FILE_COMPAT  = "#{ENV['HOME']}/.config/conky/pim.yml"

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

    def get_ics
      uri_ics = {}

      uris  = @config['calendar']['holiday_uris']
      uris += @config['event']['schedule_uris']

      uris.each do |uri|
        temp_prefix = File.basename(uri)
        ics_io = Tempfile.new(temp_prefix)

        open(uri) { |io| ics_io.write(io.read) }

        uri_ics[uri] = ics_io
      end

      uri_ics
    end

    def clean_ics(uri_ics)
      uri_ics.each do |uri, ics_io|
        ics_io.close
        ics_io.unlink
      end
    end

    def all
      uri_ics = get_ics
      Calendar.new(@options, @config, uri_ics).generate
      Event.new(@options, @config, uri_ics).show
      clean_ics(uri_ics)
    end

    def calendar
      uri_ics = get_ics
      Calendar.new(@options, @config, uri_ics).generate
      clean_ics(uri_ics)
    end

    def event
      uri_ics = get_ics
      Event.new(@options, @config, uri_ics).show
      clean_ics(uri_ics)
    end

    def debug
      pp @options
      pp @config
      uri_ics = get_ics
      Calendar.new(@options, @config, uri_ics, true).generate
      Event.new(@options, @config, uri_ics, true).show
      clean_ics(uri_ics)
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

