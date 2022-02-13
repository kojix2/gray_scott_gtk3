# gray_scott_gtk3

[![Gem](https://img.shields.io/gem/v/gray_scott_gtk3)](https://rubygems.org/gems/gray_scott_gtk3)
[![test](https://github.com/kojix2/Gray-Scott/actions/workflows/ci.yml/badge.svg)](https://github.com/kojix2/Gray-Scott/actions/workflows/ci.yml)
[![DOI](https://zenodo.org/badge/158914232.svg)](https://zenodo.org/badge/latestdoi/158914232)

Ruby implementation of the [Reaction diffusion system](https://en.wikipedia.org/wiki/Reaction%E2%80%93diffusion_system) (Gray-Scott model).

![screenshot](https://raw.githubusercontent.com/kojix2/Gray-Scott/screenshot/screenshot/screenshot.gif)

## Installation

```bash
gem install gray_scott_gtk3
```

Support GPGPU with [Cumo](https://github.com/sonots/cumo).

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

    Do you need commit rights to my repository?
    Do you want to get admin rights and take over the project?
    If so, please feel free to contact me @kojix2.
