require 'spec_helper'

RSpec.describe GrayScott::Controller do
  before do
    @controller = GrayScott::Controller.new 'resources/'
  end

  it 'has model' do
    expect(@controller.model).to be_an_instance_of GrayScott::Model
  end

  it 'has color' do
    expect(@controller.color).to eq 'colorful'
  end

  it 'respond to doing_now?' do
    expect(@controller).to respond_to :doing_now?
  end

end
