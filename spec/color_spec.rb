# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GrayScott::Color do
  subject(:colorizer) { Class.new { include GrayScott::Color }.new }

  it 'renders the maximum channel value without wrapping to zero' do
    pixels = colorizer.colorize(SFloat[[1.0]], 'red')

    expect(pixels.to_a).to eq [[[255, 0, 0]]]
  end

  it 'renders HSV sector boundaries correctly' do
    pixels = colorizer.colorize(SFloat[[0.5, 1.0]], 'colorful')

    expect(pixels.to_a).to eq [[[0, 255, 255], [255, 0, 0]]]
  end
end
