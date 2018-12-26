module GrayScott
  class Model
    include XumoShortHand 

    Dx = 0.01
    Dt = 1

    Du = 2e-5
    Dv = 1e-5

    attr_accessor :f, :k, :u, :v

    def initialize(width: 256, height: 256)
      # Feed rate
      @f = 0.04
      # Kill rate
      @k = 0.06

      @u = SFloat.ones height, width
      @v = SFloat.zeros height, width
    end

    def clear
      u.fill 1.0
      v.fill 0.0
    end

    def update
      l_u = Utils::Math._laplacian2d u, Dx
      l_v = Utils::Math._laplacian2d v, Dx

      uvv = u * v * v
      dudt = Du * l_u - uvv + f * (1.0 - u)
      dvdt = Dv * l_v + uvv - (f + k) * v
      u._ + (Dt * dudt)
      v._ + (Dt * dvdt)
      immune_surveillance
    end

    def immune_surveillance
      # clip is better.
      @u[@u.lt 0.00001] = 0.00001
      @u[@u.gt 1] = 1
      @v[@v.lt 0.00001] = 0.00001
      @v[@v.gt 1] = 1
    end
  end
end
