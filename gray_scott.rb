require 'numo/narray'
require 'gtk3'

# 短縮
class Numo::SFloat
  alias _ inplace
end
SFloat = Numo::SFloat
UInt8  = Numo::UInt8

# パラメータ
Dx = 0.01
Dt = 1
Du = 2e-5
Dv = 1e-5
@f = 0.04
@k = 0.06

# 初期化
@u = SFloat.ones 256, 256
@v = SFloat.zeros 256, 256

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

def on_window_destroy
  Gtk.main_quit
end

def on_new_button_clicked
  @u.fill 1.0
  @v.fill 0.0
  @gimage.pixbuf = to_pixbuf @u
end

def on_f_changed(f)
  @f = f.value
end

def on_k_changed(k)
  @k = k.value
end

def on_save_button_clicked
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

def on_switch_changed(_w, active)
  @flag = active
  if active
    GLib::Timeout.add 25 do
      update_u_v
      @gimage.pixbuf = to_pixbuf @u
      @flag
    end
  end
end

def on_motion(_widget, e)
  x = e.x / 2
  y = e.y / 2
  if x > 5 && y > 5 && x < 250 && y < 250
    @v[(y - 2)..(y + 2), (x - 2)..(x + 2)] = 0.5
  end
  unless @flag
    @gimage.pixbuf = to_pixbuf @v
  end
end

def to_image_string(ar)
  #data = UInt8.new(256, 256, 3).fill 0
  #data[true, true, 1] = UInt8.cast(256 - ar * 256)
  data = hsv2rgb(ar)
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
  p = UInt8.zeros(256,256,1)
  v = UInt8.new(256, 256,1).fill 255
  q = (1.0 - f) * 256
  t = f * 256
  rgb = UInt8.zeros 256, 256, 3
  h = h.expand_dims(2)
  t = UInt8.cast(t).expand_dims(2)
  i = UInt8.dstack([i,i,i])
  fuga = i.eq 0
  rgb[i.eq 0] = UInt8.dstack([v,t,p])[i.eq 0]
  rgb[i.eq 1] = UInt8.dstack([q,v,p])[i.eq 1]
  rgb[i.eq 2] = UInt8.dstack([p,v,t])[i.eq 2]
  rgb[i.eq 3] = UInt8.dstack([p,q,v])[i.eq 3]
  rgb[i.eq 4] = UInt8.dstack([t,p,v])[i.eq 4]
  rgb[i.eq 5] = UInt8.dstack([v,p,q])[i.eq 5]
  rgb
end

builder = Gtk::Builder.new
builder.add_from_file 'gray_scott.glade'
win = builder.get_object 'win'
@gimage = builder.get_object 'gimage'
builder.connect_signals { |handler| method(handler) }

win.show_all
Gtk.main
