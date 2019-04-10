if Object.const_defined? :Cumo
  Xumo = Cumo
else
  require 'numo/narray'
  Xumo = Numo
end

module XumoShortHand
  class Xumo::SFloat
    alias _ inplace
  end
  SFloat = Xumo::SFloat
  UInt8  = Xumo::UInt8
end

require 'grayscott/model'
require 'grayscott/color'
require 'grayscott/math'
require 'grayscott/version'

module GrayScott
  class Error < StandardError; end
end
