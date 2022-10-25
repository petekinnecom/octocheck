
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "octocheck/version"

Gem::Specification.new do |spec|
  spec.name          = "octocheck"
  spec.version       = Octocheck::VERSION
  spec.authors       = ["Pete Kinnecom"]
  spec.email         = ["git@k7u7.com"]

  spec.summary       = "See github checks in your terminal"
  spec.homepage      = "https://github.com/petekinnecom/octocheck"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
end
