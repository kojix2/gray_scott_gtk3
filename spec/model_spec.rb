require 'spec_helper'

RSpec.describe GrayScottGtk3::Model do
  before do
    @model = GrayScottGtk3::Model.new
  end

  it 'has feed rate' do
    expect(@model.f).to eq 0.04
  end

  it 'has kill rate' do
    expect(@model.k).to eq 0.06
  end

  it 'has u' do
    expect(@model.u).to be_an_instance_of Numo::SFloat
  end

  it 'has v' do
    expect(@model.v).to be_an_instance_of Numo::SFloat
  end

  it 'respond to clear' do
    expect(@model).to respond_to :clear
  end

  it 'respond to update' do
    expect(@model).to respond_to :update
  end
end
