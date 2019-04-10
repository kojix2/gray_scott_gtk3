require 'grayscott'

model = GrayScott::Model.new width: 1024, height: 1024

na = Numo::SFloat.new(1024, 1).seq + 10 # avoid zero
na *= Numo::SFloat.ones(1, 1024)
na /= na.max
f = na * 0.05
k = na.transpose * 0.06 + 0.01
model.f = f
model.k = k
model.v.rand(0.0, 0.15)

1000.times do |i|
  p i
  model.update
end

require 'gtk3'
data = GrayScott::Color.colorize(model.u, 'reverse-colorful')
pixbuf = GdkPixbuf::Pixbuf.new data: data.to_string, width: 1024, height: 1024
pixbuf.scale_simple 512, 512, :bilinear
pixbuf.save 'example1.png', :png
