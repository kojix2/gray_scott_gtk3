module GrayScott
  module Color
    include XumoShortHand

    def colorize(ar, color_type)
      case color_type
      when 'colorful'
        hsv2rgb(ar)
      when 'reverse-colorful'
        hsv2rgb(1.0 - ar)
      when 'red'
        red(ar)
      when 'green'
        green(ar)
      when 'blue'
        blue(ar)
      when 'reverse-red'
        reverse_red(ar)
      when 'reverse-green'
        reverse_green(ar)
      when 'reverse-blue'
        reverse_blue(ar)
      end
    end

    def hsv2rgb(h)
      height, width = h.shape
      i = UInt8.cast(h * 6)
      f = (h * 6.0) - i
      p = UInt8.zeros height, width, 1
      v = UInt8.new(height, width, 1).fill 255
      q = (1.0 - f) * 256
      t = f * 256
      rgb = UInt8.zeros height, width, 3
      t = UInt8.cast(t).expand_dims(2)
      i = UInt8.dstack([i, i, i])
      rgb[i.eq 0] = UInt8.dstack([v, t, p])[i.eq 0]
      rgb[i.eq 1] = UInt8.dstack([q, v, p])[i.eq 1]
      rgb[i.eq 2] = UInt8.dstack([p, v, t])[i.eq 2]
      rgb[i.eq 3] = UInt8.dstack([p, q, v])[i.eq 3]
      rgb[i.eq 4] = UInt8.dstack([t, p, v])[i.eq 4]
      rgb[i.eq 5] = UInt8.dstack([v, p, q])[i.eq 5]
      rgb
    end

    def red(ar)
      uint8_zeros_256(0, ar)
    end

    def green(ar)
      uint8_zeros_256(1, ar)
    end

    def blue(ar)
      uint8_zeros_256(2, ar)
    end

    def reverse_red(ar)
      uint8_zeros_256(0, (1.0 - ar))
    end

    def reverse_green(ar)
      uint8_zeros_256(1, (1.0 - ar))
    end

    def reverse_blue(ar)
      uint8_zeros_256(2, (1.0 - ar))
    end

    private

    def uint8_zeros_256(ch, ar)
      d = UInt8.zeros(*ar.shape, 3)
      d[true, true, ch] = UInt8.cast(ar * 256)
      d
    end
  end
end
