# frozen_string_literal: true

require_relative 'controller/aboutdialog'

module GrayScott
  class Controller
    include Color
    include XumoShortHand
    attr_accessor :resource_dir, :height, :width, :model, :color

    def initialize(dir, height: 256, width: 256)
      @resource_dir = dir
      @height = height
      @width = width
      @model = Model.new(height: height, width: width)
      @show_u = false
      @color = 'colorful'
      @frames = 5
      @msec = 40

      builder = Gtk::Builder.new
      builder.add_from_file File.join(resource_dir, 'gray_scott.glade')

      %w[win execute_button gimage legend_image uv_combobox pen_density pen_radius].each do |s|
        instance_variable_set('@' + s, builder.get_object(s))
      end

      builder.connect_signals { |handler| method(handler) }

      @win.show_all # window
      on_clear_clicked
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

    def on_frames_changed(frames)
      @frames = frames.value.to_i
    end

    def on_msec_changed(msec)
      @msec = msec.value.to_i
    end

    def display
      @gimage.pixbuf = create_pixbuf(colorize((@show_u ? model.u : model.v), @color))
    end

    def display_legend
      legend = (SFloat.new(1, 512).seq * SFloat.ones(16, 1)) / 512.0
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
      GLib::Timeout.add @msec do
        @frames.times do
          model.update
        end
        display
        @doing_now
      end
    end

    def stop
      @doing_now = false
      @execute_button.active = false
    end

    def on_open_clicked
      stop if doing_now?
      dialog = Gtk::FileChooserDialog.new(title: 'Open Gray-Scott Model',
                                          action: :open,
                                          buttons: [%i[open accept], %i[cancel cancel]])
      if dialog.run == :accept
        filename = dialog.filename
        str = File.read(filename)
        # TODO: check model
        @model = Marshal.load(str)
        display
      end
      dialog.destroy
    end

    def on_save_clicked
      stop if doing_now?
      dialog = Gtk::FileChooserDialog.new(title: 'Save Gray-Scott Model',
                                          action: :save,
                                          buttons: [%i[save accept], %i[cancel cancel]])
      dialog.do_overwrite_confirmation = true
      if dialog.run == :accept
        filename = dialog.filename
        str = Marshal.dump(model)
        File.write(filename, str)
      end
      dialog.destroy
    end

    def on_convert_clicked
      stop if doing_now?
      dialog = Gtk::FileChooserDialog.new(title: 'Save PNG image',
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

    def on_clear_clicked
      model.clear
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

    def create_pixbuf(ar)
      data = ar.to_string
      height, width = ar.shape
      pixbuf = GdkPixbuf::Pixbuf.new data: data, width: width, height: height
      pixbuf.scale_simple 512, 512, :bilinear
    end

    def doing_now?
      @doing_now
    end

    private

    def debug_p_u
      p model.u
    end

    def debug_p_v
      p model.v
    end

    def debug_p_f
      p model.f
    end

    def debug_p_k
      p model.k
    end
  end
end
