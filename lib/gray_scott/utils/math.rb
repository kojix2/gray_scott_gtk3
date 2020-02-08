# frozen_string_literal: true

module GrayScott
  module Utils
    module Math
      # To avoid mistakes
      A = (1..-1).freeze
      B = (0..-2).freeze
      T = true

      def self._laplacian2d(uv, dx)
        l_uv = uv.new_zeros
        l_uv[A, T]._ + uv[B, T]
        l_uv[T, A]._ + uv[T, B]

        l_uv[0, T]._ + uv[-1, T]
        l_uv[T, 0]._ + uv[T, -1]

        l_uv[B, T]._ + uv[A, T]
        l_uv[T, B]._ + uv[T, A]

        l_uv[-1, T]._ + uv[0, T]
        l_uv[T, -1]._ + uv[T, 0]

        l_uv._ - (uv * 4)
        l_uv._ / (dx * dx)
        l_uv
      end
    end
  end
end
