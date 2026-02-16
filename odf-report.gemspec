$:.push File.expand_path("../lib", __FILE__)
require "odf-report/version"

Gem::Specification.new do |s|
  s.name = "odf-report"
  s.version = ODFReport::VERSION

  s.authors = ["Sandro Duarte"]
  s.description = "Generates ODF files, given a template (.odt) and data, replacing tags"
  s.email = "sandrods@gmail.com"
  s.homepage = "http://sandrods.github.com/odf-report/"
  s.summary = "Generates ODF files, given a template (.odt) and data, replacing tags"

  s.files = `git ls-files -z`.split("\x0")
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.0.0"
  s.add_development_dependency "faker"
  s.add_development_dependency "launchy"

  s.add_runtime_dependency("rubyzip", ">= 1.3.0")
  s.add_runtime_dependency("nokogiri", ">= 1.12.0")
  s.add_runtime_dependency("mime-types")
end
