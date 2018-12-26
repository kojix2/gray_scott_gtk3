# Gray-Scott

![screenshot](https://raw.githubusercontent.com/kojix2/Gray-Scott/screenshot/screenshot/screenshot.gif)

## Requirements

* Ruby
* Numo/NArray (CPU)
  * Cumo/NArray (GPU)
* Ruby/Gtk3

## Installation

$ gem install gray_scott_gtk3

## Usage

$ grayscott 40 # msec

$ grayscott 40 -w 256 -h 256 # size of model. display is fixed to 512 x 512 pixels.

## Usage with terminal(example)

$ bundle install

$ bundle exec bin/console

```ruby
GrayScott::Controller::MSEC = 50
c = GrayScott::Controller.new 'resources/', width:1024, height:1024

# custom feed / kill ratio
na = Numo::SFloat.new(1024,1).seq + 10 # avoid zero
na = na * Numo::SFloat.ones(1, 1024)
na = na / na.max
f = na * 0.05
k = na.transpose * 0.06 + 0.01
c.model.f = f
c.model.k = k
c.model.v.rand(0.0, 0.15)
c.color = 'reverse_green' # colorful is slow. 
Gtk.main
```

![screenshot](https://raw.githubusercontent.com/kojix2/Gray-Scott/screenshot/screenshot/reverse-green.png)

## Known issue

Glib::Timeout.add(number_of_seconds)
If processing can not be completed within the time, it will not be displayed. 
In this case, you should increase the number of seconds.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/Gray-Scott.
