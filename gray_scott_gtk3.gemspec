
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gray_scott_gtk3/version"

Gem::Specification.new do |spec|
  spec.name          = "gray_scott_gtk3"
  spec.version       = GrayScottGtk3::VERSION
  spec.authors       = ["kojix2"]
  spec.email         = ["2xijok@gmail.com"]

  spec.summary       = %q{Gray-Scott model.}
  spec.description   = %q{Gray-Scott model.}
  spec.homepage      = "https://github.com/kojix2/Gray-Scott"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "numo-narray"
  # RSVG2: May not work with gtk3 alone
  spec.add_dependency "rsvg2"
  spec.add_dependency "gtk3"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
end
