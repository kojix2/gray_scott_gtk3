# frozen_string_literal: true

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

  it 'loads validated JSON model data' do
    data = {
      version: 1,
      width: 2,
      height: 2,
      f: 0.04,
      k: 0.06,
      u: [[1.0, 1.0], [1.0, 1.0]],
      v: [[0.0, 0.5], [0.5, 0.0]]
    }.to_json

    model = @controller.send(:load_model, data)

    expect(model.u.to_a).to eq [[1.0, 1.0], [1.0, 1.0]]
    expect(model.v.to_a).to eq [[0.0, 0.5], [0.5, 0.0]]
  end

  it 'rejects non-JSON model data' do
    expect { @controller.send(:load_model, Marshal.dump(@controller.model)) }
      .to raise_error(JSON::ParserError)
  end

  it 'keeps only one simulation timer active' do
    @controller.execute
    timeout_id = @controller.instance_variable_get(:@timeout_id)
    @controller.execute

    expect(@controller.instance_variable_get(:@timeout_id)).to eq timeout_id
  ensure
    @controller.stop
  end
end
