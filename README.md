# Gray-Scott

[![Gem](https://img.shields.io/gem/v/gray_scott_gtk3)](https://rubygems.org/gems/gray_scott_gtk3)
[![build status](https://travis-ci.com/kojix2/Gray-Scott.svg?branch=master)](https://travis-ci.com/github/kojix2/Gray-Scott)

Ruby implementation of the Reaction diffusion system (Gray-Scott model).

![screenshot](https://raw.githubusercontent.com/kojix2/Gray-Scott/screenshot/screenshot/screenshot.gif)

## Installation

```bash
gem install gray_scott_gtk3
```

## Usage

```bash
grayscott
```

```bash
grayscott --help
# Usage: grayscott [options]
#    -h, --height val                 height of the model
#    -w, --width val                  width of the model
#    -g, --gpu                        use GPU(Cumo)
```

NOTE : You can set the width and height of the model, but the width and height of the window is fixed at 512 x 512 pixels.

![screenshot](https://raw.githubusercontent.com/kojix2/Gray-Scott/screenshot/screenshot/reverse-green.png)

## Known issue

Glib::Timeout.add(number_of_seconds)
If processing can not be completed within the time, it will not be displayed.
In this case, you should increase the number of seconds.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kojix2/Gray-Scott.
