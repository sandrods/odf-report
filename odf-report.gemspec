# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "odf-report/version"

Gem::Specification.new do |s|
  s.name = %q{odf-report}
  s.version = ODFReport::VERSION

  s.authors = ["Sandro Duarte"]
  s.description = %q{Generates ODF files, given a template (.odt) and data, replacing tags}
  s.email = %q{sandrods@gmail.com}
  s.has_rdoc = false
  s.homepage = %q{http://sandrods.github.com/odf-report/}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Generates ODF files, given a template (.odt) and data, replacing tags}

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.6"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "faker"
  s.add_development_dependency "launchy"

  s.add_runtime_dependency('rubyzip', "~> 1.1.0")
  s.add_runtime_dependency('nokogiri', ">= 1.5.0")

end
