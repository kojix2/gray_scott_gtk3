require_relative 'controller/aboutdialog'

module GrayScottGtk3
  class Controller
    include ShortNumo
    attr_accessor :resource_dir, :height, :width, :model

    def initialize(dir, height: 256, width: 256)
      @resource_dir = dir
      @height = height
      @width = width
      @model = Model.new(height: height, width: width)
      @show_u = true
      @color = 'colorful'

      builder = Gtk::Builder.new
      builder.add_from_file File.join(resource_dir, 'gray_scott.glade')

      %w[win gimage legend_image uv_combobox pen_density pen_radius].each do |s|
        instance_variable_set('@' + s, builder.get_object(s))
      end

      builder.connect_signals { |handler| method(handler) }

      @win.show_all # window
      Gtk.main
    end

    def show_about
      AboutDialog.new resource_dir
    end

    def on_f_changed(f)
      model.f = f.value
    end

    def on_k_changed(k)
      model.k = k.value
    end

    def display
      @gimage.pixbuf = to_pixbuf(@show_u ? model.u : model.v)
    end

    def display_legend
      legend = (SFloat.new(1, 512).seq * SFloat.ones(16, 1)) / 512
      data = colorize(legend, @color)
      string = data.to_string
      pixbuf = GdkPixbuf::Pixbuf.new data: string, width: 512, height: 16
      @legend_image.pixbuf = pixbuf
    end

    def on_execute_toggled(widget)
      if widget.active?
        execute
      else
        @doing_now = false
      end
    end

    def execute
      @doing_now = true
      GLib::Timeout.add MSEC do
        model.update
        display
        @doing_now
      end
    end

    def on_save_clicked
      @doing_now = false

      dialog = Gtk::FileChooserDialog.new(title: 'PNG画像を保存',
                                          action: :save,
                                          buttons: [%i[save accept], %i[cancel cancel]])
      dialog.do_overwrite_confirmation = true
      if dialog.run == :accept
        filename = dialog.filename
        @gimage.pixbuf.save(filename, :png)
      end
      dialog.destroy
    end

    def main_quit
      Gtk.main_quit
    end

    def on_new_clicked
      model.clear
      if @show_u && !@doing_now
        dialog = Gtk::MessageDialog.new(message: 'display V density',
                                        type: :info,
                                        tutton_type: :close)
        dialog.run
        @uv_combobox.active = 1 # v
        dialog.destroy
      end
      display_legend
      display
    end

    def on_uv_combobox_changed(w)
      @show_u = w.active_text == 'U'
      display unless doing_now?
    end

    def on_color_combobox_changed(w)
      @color = w.active_text
      display_legend
      display unless doing_now?
    end

    def on_motion(_widget, e)
      x = e.x * width / 512
      y = e.y * height / 512
      r = @pen_radius.value
      if x > r && y > r && x < (width - 1 - r) && y < (height - 1 - r)
        model.v[(y - r)..(y + r), (x - r)..(x + r)] = @pen_density.value
      end
      display unless doing_now?
    end

    def colorize(ar, color_type)
      case color_type
      when 'colorful'
        hsv2rgb(ar)
      when 'reverse-colorful'
        hsv2rgb(1.0 - ar)
      when 'red'
        uint8_zeros_256(0, ar)
      when 'green'
        uint8_zeros_256(1, ar)
      when 'blue'
        uint8_zeros_256(2, ar)
      when 'reverse-red'
        uint8_zeros_256(0, (1.0 - ar))
      when 'reverse-green'
        uint8_zeros_256(1, (1.0 - ar))
      when 'reverse-blue'
        uint8_zeros_256(2, (1.0 - ar))
      end
    end

    def uint8_zeros_256(ch, ar)
      d = UInt8.zeros(*ar.shape, 3)
      d[true, true, ch] = UInt8.cast(ar * 256)
      d
    end

    def to_pixbuf(ar, color_type = @color)
      data = colorize(ar, color_type).to_string
      height, width = ar.shape
      pixbuf = GdkPixbuf::Pixbuf.new data: data, width: width, height: height
      pixbuf.scale_simple 512, 512, :bilinear
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

    def doing_now?
      @doing_now
    end
  end
end
