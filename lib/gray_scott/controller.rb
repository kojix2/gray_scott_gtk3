# frozen_string_literal: true

require 'json'

require_relative 'controller/aboutdialog'

module GrayScott
  class Controller
    include Color
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
        instance_variable_set("@#{s}", builder.get_object(s))
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
      @msec = [msec.value.to_i, 1].max
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
        stop
      end
    end

    def execute
      return if @timeout_id

      @doing_now = true
      @timeout_id = GLib::Timeout.add([@msec, 1].max) do
        @frames.times do
          model.step
        end
        display
        if @doing_now
          true
        else
          @timeout_id = nil
          false
        end
      end
    end

    def stop
      @doing_now = false
      if @timeout_id
        GLib::Source.remove(@timeout_id)
        @timeout_id = nil
      end
      @execute_button.active = false
    end

    def on_open_clicked
      stop if doing_now?
      dialog = Gtk::FileChooserDialog.new(title: 'Open Gray-Scott Model',
                                          action: :open,
                                          buttons: [%i[open accept], %i[cancel cancel]])
      if dialog.run == :accept
        begin
          @model = load_model(File.read(dialog.filename))
          @height, @width = @model.u.shape
          display
        rescue JSON::ParserError, ArgumentError, KeyError, TypeError => e
          warn "Unable to open model: #{e.message}"
        end
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
        File.write(dialog.filename, JSON.generate(model_data))
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

    def model_data
      height, width = model.u.shape
      {
        version: 1,
        width: width,
        height: height,
        f: model.f,
        k: model.k,
        u: model.u.to_a,
        v: model.v.to_a
      }
    end

    def load_model(serialized)
      data = JSON.parse(serialized)
      version = data.fetch('version')
      width = data.fetch('width')
      height = data.fetch('height')
      f = data.fetch('f')
      k = data.fetch('k')
      u = data.fetch('u')
      v = data.fetch('v')

      unless version == 1 &&
             [width, height].all? { |dimension| dimension.is_a?(Integer) && dimension >= 2 } &&
             [f, k].all? { |value| value.is_a?(Numeric) && value.finite? } &&
             [u, v].all? { |array| valid_model_array?(array, height, width) }
        raise ArgumentError, 'invalid model data'
      end

      Model.new(width: width, height: height).tap do |loaded_model|
        loaded_model.f = f
        loaded_model.k = k
        loaded_model.u = SFloat.cast(u)
        loaded_model.v = SFloat.cast(v)
      end
    end

    def valid_model_array?(array, height, width)
      array.is_a?(Array) && array.length == height &&
        array.all? do |row|
          row.is_a?(Array) && row.length == width &&
            row.all? { |value| value.is_a?(Numeric) && value.finite? }
        end
    end

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
