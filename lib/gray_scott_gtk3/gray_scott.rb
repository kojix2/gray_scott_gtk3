module GrayScottGtk3
  class ViewController
    def initialize(resource_dir)
      @height = 256
      @width = 256
      builder = Gtk::Builder.new
      builder.add_from_file File.join(resource_dir, "gray_scott.glade")

      %w[win gimage legend_image uv_combobox pen_density pen_radius].each do |s|
        instance_variable_set('@' + s, builder.get_object(s))
      end

      builder.connect_signals { |handler| method(handler)}

      @win.show_all
      Gtk.main
    end

    def show_about
      a = Gtk::AboutDialog.new
      a.program_name = 'Gray-Scott'
      a.logo = GdkPixbuf::Pixbuf.new(file: File.join(resource_dir, 'about_icon.png'))
      a.authors = ['kojix2']
      a.run
      a.destroy
    end

    def on_f_changed(f)
      @f = f.value
    end

    def on_k_changed(k)
      @k = k.value
    end

    def display
      @gimage.pixbuf = to_pixbuf(@show_u ? @u : @v)
    end

    def display_legend
      legend = (SFloat.new(1, 512).seq * SFloat.ones(24, 1)) / 512
      data = colorize(legend, @color).to_string
      pixbuf = GdkPixbuf::Pixbuf.new data: data, width: 512, height: 24
      @legend_image.pixbuf = pixbuf
    end

    def on_execute_toggled(widget)
      @doing_now = widget.active?
      if @doing_now
        GLib::Timeout.add MSEC do
          update_u_v
          display
          @doing_now
        end
      end
    end

    def on_save_clicked
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
      @u.fill 1.0
      @v.fill 0.0
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
      @show_u = w.active_text == 'u'
      display unless @doing_now
    end
    
    def on_color_combobox_changed(w)
      @color = w.active_text
      display_legend
      display unless @doing_now
    end

    def on_motion(_widget, e)
      x = e.x * @width / 512
      y = e.y * @height / 512
      r = @pen_radius.value
      if x > r && y > r && x < (@height - 1 - r) && y < (@width - 1 - r)
        @v[(y - r)..(y + r), (x - r)..(x + r)] = @pen_density.value
      end
      display unless @doing_now
    end
  end
end
