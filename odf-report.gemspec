# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{odf-report}
  s.version = "0.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sandro Duarte"]
  s.date = %q{2009-07-28}
  s.description = %q{Generates ODF files, given a template (.odt) and data, replacing tags}
  s.email = %q{sandrods@gmail.com}
  s.extra_rdoc_files = ["lib/odf-report.rb", "README.textile"]
  s.files = ["lib/odf-report.rb", "odf-report.gemspec", "Rakefile", "README.textile", "test/test.odt", "test/test.rb", "Manifest"]
  s.has_rdoc = true
  s.homepage = %q{}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Odf-report", "--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{odf-report}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Generates ODF files, given a template (.odt) and data, replacing tags}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rubyzip>, [">= 0", "= 0.9.1"])
    else
      s.add_dependency(%q<rubyzip>, [">= 0", "= 0.9.1"])
    end
  else
    s.add_dependency(%q<rubyzip>, [">= 0", "= 0.9.1"])
  end
end
