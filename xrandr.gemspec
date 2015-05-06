# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xrandr'

Gem::Specification.new do |spec|
  spec.name          = "xrandr"
  spec.version       = Xrandr::VERSION
  spec.authors       = ["Fernando Martínez"]
  spec.email         = ["fernando.martinez@live.com.ar"]
  spec.summary       = %q{ A ruby wrapper for Xrandr }
  spec.description   = ''
  spec.homepage      = "https://github.com/f-3r/xrandr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "minitest"
end
