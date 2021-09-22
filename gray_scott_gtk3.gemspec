# frozen_string_literal: true

require_relative 'lib/gray_scott/version'

Gem::Specification.new do |spec|
  spec.name          = 'gray_scott_gtk3'
  spec.version       = GrayScott::VERSION
  spec.authors       = ['kojix2']
  spec.email         = ['2xijok@gmail.com']

  spec.summary       = 'Gray-Scott model.'
  spec.description   = 'Reaction diffusion system (Gray-Scott model).'
  spec.homepage      = 'https://github.com/kojix2/Gray-Scott'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = ['grayscott']
  spec.require_paths = ['lib']

  spec.add_dependency 'gtk3'
  spec.add_dependency 'numo-narray'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
