# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fs-communicator}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jimmy Zimmerman"]
  s.date = %q{2009-03-04}
  s.description = %q{TODO}
  s.email = %q{jimmy.zimmerman@gmail.com}
  s.files = ["VERSION.yml", "lib/assets", "lib/assets/entrust-ca.crt", "lib/fs_communicator.rb", "spec/fs_communicator_spec.rb", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jimmyz/fs-communicator}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
