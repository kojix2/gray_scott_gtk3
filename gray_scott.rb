require 'numo/narray'
require 'gtk3'

# 短縮
class Numo::SFloat
  alias _ inplace
end
SFloat = Numo::SFloat
UInt8  = Numo::UInt8

# Timeout用秒数 MSEC 設定
if ARGV[0]
  msec = ARGV[0].to_i
else
  puts 'please specify command-line argument. For example `ruby gray_scott.rb 40`'
  exit
end
MSEC = msec

# パラメータ
Dx = 0.01
Dt = 1
# Diffusion rates
Du = 2e-5
Dv = 1e-5
# Feed rate
@f = 0.04
# Kill rate
@k = 0.06

# 初期化
@u = SFloat.zeros 256, 256
@v = SFloat.zeros 256, 256
@show_u = true
@color = 'colorful'

# 間違いよけ
A = (1..-1).freeze
B = (0..-2).freeze
T = true
def laplacian(uv)
  l_uv = SFloat.zeros 256, 256
  l_uv[A, T]._ + uv[B, T]
  l_uv[T, A]._ + uv[T, B]

  l_uv[0, T]._ + uv[-1, T]
  l_uv[T, 0]._ + uv[T, -1]

  l_uv[B, T]._ + uv[A, T]
  l_uv[T, B]._ + uv[T, A]

  l_uv[-1, T]._ + uv[0, T]
  l_uv[T, -1]._ + uv[T, 0]

  l_uv._ - (uv * 4)
  l_uv._ / (Dx * Dx)
  l_uv
end

def update_u_v(u = @u, v = @v)
  l_u = laplacian u
  l_v = laplacian v

  uvv = u * v * v
  dudt = Du * l_u - uvv + @f * (1.0 - u)
  dvdt = Dv * l_v + uvv - (@f + @k) * v
  u._ + (Dt * dudt)
  v._ + (Dt * dvdt)
  @u = u
  @v = v
end

def main_quit
  Gtk.main_quit
end

def on_new_clicked
  @u.fill 0.0
  @v.fill 0.0
  if @show_u && !@doing_now
    dialog = Gtk::MessageDialog.new(message: "display V density",
                                    type: :info,
                                    tutton_type: :close)
    dialog.run
    @uv_combobox.active = 1 # v
    dialog.destroy
  end
  display
end

def on_f_changed(f)
  @f = f.value
end

def on_k_changed(k)
  @k = k.value
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

def display
  @gimage.pixbuf = if @show_u
                     to_pixbuf @u
                   else
                     to_pixbuf @v
                   end
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

def on_motion(_widget, e)
  x = e.x / 2
  y = e.y / 2
  r = @pen_radius.value
  if x > r && y > r && x < (255-r) && y < (255-r)
    @v[(y - r)..(y + r), (x - r)..(x + r)] = @pen_density.value
  end
  display unless @doing_now
end

def on_uv_combobox_changed(w)
  @show_u = w.active_text == 'u'
  display unless @doing_now
end

def on_color_combobox_changed(w)
  @color = w.active_text
  display unless @doing_now
end

def uint8_zeros_256(ch, ar)
  d = UInt8.zeros(256, 256, 3)
  d[true, true, ch] = UInt8.cast(ar * 256)
  d
end

def to_image_string(ar)
  data = case @color
         when 'colorful'
           hsv2rgb(1.0 - ar)
         when 'reverse-colorful'
           hsv2rgb(ar)
         when 'red'
           uint8_zeros_256(0, (1.0 - ar))
         when 'green'
           uint8_zeros_256(1, (1.0 - ar))
         when 'blue'
           uint8_zeros_256(2, (1.0 - ar))
         when 'reverse-red'
           uint8_zeros_256(0, ar)
         when 'reverse-green'
           uint8_zeros_256(1, ar)
         when 'reverse-blue'
           uint8_zeros_256(2, ar)
  end
  data.to_string
end

def to_pixbuf(ar)
  string = to_image_string(ar)
  pixbuf = GdkPixbuf::Pixbuf.new data: string, width: 256, height: 256
  pixbuf.scale_simple 512, 512, :bilinear
end

def hsv2rgb(h)
  i = UInt8.cast(h * 6)
  f = (h * 6.0) - i
  p = UInt8.zeros(256, 256, 1)
  v = UInt8.new(256, 256, 1).fill 255
  q = (1.0 - f) * 256
  t = f * 256
  rgb = UInt8.zeros 256, 256, 3
  h = h.expand_dims(2)
  t = UInt8.cast(t).expand_dims(2)
  i = UInt8.dstack([i, i, i])
  fuga = i.eq 0
  rgb[i.eq 0] = UInt8.dstack([v, t, p])[i.eq 0]
  rgb[i.eq 1] = UInt8.dstack([q, v, p])[i.eq 1]
  rgb[i.eq 2] = UInt8.dstack([p, v, t])[i.eq 2]
  rgb[i.eq 3] = UInt8.dstack([p, q, v])[i.eq 3]
  rgb[i.eq 4] = UInt8.dstack([t, p, v])[i.eq 4]
  rgb[i.eq 5] = UInt8.dstack([v, p, q])[i.eq 5]
  rgb
end

# MenuBar
def show_about
  a = Gtk::AboutDialog.new
  a.program_name = "Gray-Scott"
  a.logo   = GdkPixbuf::Pixbuf.new(file: File.join(__dir__, 'screenshot/about_icon.png'))
  a.authors = ["kojix2"]
  a.run
  a.destroy
end

builder = Gtk::Builder.new
builder.add_from_file 'gray_scott.glade'
@win = builder.get_object 'win'
@gimage = builder.get_object 'gimage'
@uv_combobox = builder.get_object 'uv_combobox'
@pen_density = builder.get_object 'pen_density'
@pen_radius  = builder.get_object 'pen_radius'
builder.connect_signals { |handler| method(handler) }

@win.show_all
Gtk.main
