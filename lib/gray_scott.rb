# frozen_string_literal: true

require 'gtk3'

if Object.const_defined? :Cumo
  Xumo = Cumo
else
  require 'numo/narray'
  Xumo = Numo
end

module XumoShortHand
  module Xumo
    class SFloat
      alias _ inplace
    end
  end
  SFloat = Xumo::SFloat
  UInt8  = Xumo::UInt8
end

require 'gray_scott/model'
require 'gray_scott/color'
require 'gray_scott/controller'
require 'gray_scott/utils/math'
require 'gray_scott/version'

module GrayScott
  class Error < StandardError; end
end
