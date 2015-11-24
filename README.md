# ConkyJCalendar

Japanese calendar for conky. This highlights Japanese holidays in conky.

## Installation

Add the following line to `${HOME}/Gemfile`:

```ruby
gem 'conky-jcalendar',  :github => 'ryujinno/conky-jcalendar.rb'
```

And then execute:

```
$ bundle install --binstubs
```

`conky-jcalendar` command is installed to `${HOME}/bin`.

## Usage

```
Commands:
  conky-jcalendar conky           # Putout calendar for conky
  conky-jcalendar debug           # Putout calendar for debugging
  conky-jcalendar help [COMMAND]  # Describe available commands or one spec...

Options:
  -h, [--holiday-id=HOLIDAY_ID]        # Holiday ID of Google Calendar
  -f, [--first-weekday=FIRST_WEEKDAY]  # First day of week for calendar
  -t, [--today=TODAY]                  # Today of calendar for debugging
```

## Conky integration

Add the following line to `${HOME}/.conkyrc`:

```
${execpi 600 ${HOME}/bin/conky-jcalendar conky}
```

## Configuration

You can edit `${HOME}/.config/conky-jcalendar.yaml` as a user config file.

Default config is below:

```yaml
---
option:
  holiday_id:     'japanese__ja@holiday.calendar.google.com'
  first_weekday:  'Sunday'

style:
  voffset:        4
  font_header:    'Times:size=6'
  font_day:       'Courier:size=7'
  font_today:     'Courier:style=Bold:size=7'
  color_header:   'orange'
  color_today:    'orange'
  color_saturday: 'dodgerblue'
  color_sunday:   'violetred'
  color_holiday:  'violetred'
```

Syntax of style hash value is for conky. See `man conky` for detail.

## Contributing

1. Fork it ( https://github.com/ryujinno/conky-jcalendar.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

