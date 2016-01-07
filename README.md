# ConkyPIM

Conky personal infomation management. This shows calendar and event in Conky.

## Installation

Add the following line to `${HOME}/Gemfile`:

```ruby
gem 'conky-pim',  :github => 'ryujinno/conky-pim.rb'
```

Install gems and commands as:

```
$ bundle install --binstubs
```

`conky-pim` command is installed to `${HOME}/bin`.

## Usage

```
Commands:
  conky-pim all             # Putout calendar and event
  conky-pim calendar        # Putout calendar
  conky-pim debug           # Putout calendar and event for debugging
  conky-pim event           # Putout event
  conky-pim help [COMMAND]  # Describe available commands or one specific command

Options:
  -t, [--today=TODAY]  # Today of calendar for debugging
```

## Conky integration

Add the following line to `${HOME}/.conkyrc`:

```
${execpi 600 ${HOME}/bin/conky-pim conky}
```

## Configuration

You can edit `${HOME}/.config/conky-pim.yaml` as a user config file.

Default config is below:

```yaml
---
calendar:
  holiday_uris:
    - 'https://calendar.google.com/calendar/ical/ja.japanese%23holiday%40group.v.calendar.google.com/public/basic.ics'
  first_weekday: 'Sunday'

event:
  schedule_uris: []

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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

