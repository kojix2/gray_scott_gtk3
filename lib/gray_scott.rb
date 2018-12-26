require 'gtk3'

unless Object.const_defined? :Cumo 
  require 'numo/narray'
  Xumo = Numo
else
  Xumo = Cumo
end

module XumoShortHand
  class Xumo::SFloat
    alias _ inplace
  end
  SFloat = Xumo::SFloat
  UInt8  = Xumo::UInt8
end

require 'gray_scott/model'
require 'gray_scott/controller'
require 'gray_scott/laplacian'
require 'gray_scott/version'

module GrayScott
  class Error < StandardError; end
  # Your code goes here...
end
