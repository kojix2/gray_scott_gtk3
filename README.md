# Gray-Scott
* Ruby
* Numo/NArray
* Ruby/Gtk3

![screenshot](https://raw.githubusercontent.com/kojix2/Gray-Scott/master/screenshot/screenshot.png)

# Run

```bash
ruby grya_scott.rb 40
```

# Known issue
Glib::Timeout.add(number_of_seconds)
If processing can not be completed within the time, it will not be displayed. In this case, you should increase the number of seconds.
