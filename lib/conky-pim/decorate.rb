module ConkyPIM
  module Decorate

    def decorate_header(str)
      if @debug
        str
      else
        "${voffset #{@config['style']['voffset']}}${color #{@config['style']['color_header']}}${font #{@config['style']['font_header']}}#{str}${color} ${stippled_hr}${font #{@config['style']['font_day']}}"
      end
    end

    def decorate_day(str_day, date, today, holidays)
      if date == today
        str_day = decorate_today(str_day)
      elsif holidays.include?(date)
        str_day = decorate_holiday(str_day)
      elsif date.wday == Date::DAYNAMES.index('Saturday')
        str_day = decorate_saturday(str_day)
      elsif date.wday == Date::DAYNAMES.index('Sunday')
        str_day = decorate_sunday(str_day)
      elsif @debug
        str_day += '    '
      end

      str_day
    end

    def decorate_today(str_day)
      if @debug
        "#{str_day}:Tod"
      else
        "${font #{@config['style']['font_today']}}${color #{@config['style']['color_today']}}#{str_day}${color}${font #{@config['style']['font_day']}}"
      end
    end

    def decorate_holiday(str_day)
      if @debug
        "#{str_day}:Hol"
      else
        "${color #{@config['style']['color_holiday']}}#{str_day}${color}"
      end
    end

    def decorate_saturday(str_day)
      if @debug
        "#{str_day}:Sat"
      else
        "${color #{@config['style']['color_saturday']}}#{str_day}${color}"
      end
    end

    def decorate_sunday(str_day)
      if @debug
        "#{str_day}:Sun"
      else
        "${color #{@config['style']['color_sunday']}}#{str_day}${color}"
      end
    end

  end
end
