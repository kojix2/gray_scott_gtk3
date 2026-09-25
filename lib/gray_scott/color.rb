# frozen_string_literal: true

module GrayScott
  module Color
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
      when 'grayscale'
        grayscale(ar)
      end
    end

    # speed
    def uInt8_dstack(ar)
      x = UInt8.zeros(*ar[0].shape, 3)
      x[true, true, 0] = ar[0]
      x[true, true, 1] = ar[1]
      x[true, true, 2] = ar[2]
      x
    end

    def hsv2rgb(h)
      h = h - h.floor
      i = UInt8.cast(h * 6)
      f = (h * 6.0) - i
      p = UInt8.zeros(*h.shape)
      v = UInt8.new(*h.shape).fill 255
      q = UInt8.cast((1.0 - f) * 255)
      t = UInt8.cast(f * 255)
      rgb = UInt8.zeros(*h.shape, 3)
      i = uInt8_dstack([i, i, i])
      rgb[i.eq 0] = uInt8_dstack([v, t, p])[i.eq 0]
      rgb[i.eq 1] = uInt8_dstack([q, v, p])[i.eq 1]
      rgb[i.eq 2] = uInt8_dstack([p, v, t])[i.eq 2]
      rgb[i.eq 3] = uInt8_dstack([p, q, v])[i.eq 3]
      rgb[i.eq 4] = uInt8_dstack([t, p, v])[i.eq 4]
      rgb[i.eq 5] = uInt8_dstack([v, p, q])[i.eq 5]
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

    def grayscale(ar)
      d = ar * 255
      uInt8_dstack([d, d, d])
    end

    private

    def uint8_zeros_256(ch, ar)
      d = UInt8.zeros(*ar.shape, 3)
      d[true, true, ch] = UInt8.cast(ar * 255)
      d
    end
  end
end
