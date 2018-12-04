# Gray-Scott

![screenshot](https://raw.githubusercontent.com/kojix2/Gray-Scott/master/screenshot/screenshot.png)

## Installation

* Ruby
* Numo/NArray
* Ruby/Gtk3

    $ gem install gray_scott_gtk3

## Usage

    $ grayscott 40 # msec

## Known issue

Glib::Timeout.add(number_of_seconds)
If processing can not be completed within the time, it will not be displayed. 
In this case, you should increase the number of seconds.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/gray_scott_gtk3.
