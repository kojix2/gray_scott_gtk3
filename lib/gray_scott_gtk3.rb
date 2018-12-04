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

require 'gray_scott_gtk3/model'
require 'gray_scott_gtk3/gray_scott'
require 'gray_scott_gtk3/laplacian'
require 'gray_scott_gtk3/version'

module GrayScottGtk3
  class Error < StandardError; end
  # Your code goes here...
end
