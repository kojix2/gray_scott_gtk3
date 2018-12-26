require 'numo/narray'
require 'gtk3'

module ShortNumo
  N = Numo
  class Numo::SFloat
    alias _ inplace
  end
  SFloat = Numo::SFloat
  UInt8  = Numo::UInt8
end

require 'gray_scott/model'
require 'gray_scott/controller'
require 'gray_scott/laplacian'
require 'gray_scott/version'

module GrayScott
  class Error < StandardError; end
  # Your code goes here...
end
