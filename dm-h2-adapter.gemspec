# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dm-h2-adapter/version"

Gem::Specification.new do |s|
  s.name        = "dm-h2-adapter"
  s.version     = Dm::H2::Adapter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Akhil Kodali"]
  s.email       = [""]
  s.homepage    = ""
  s.summary     = %q{Summary}
  s.description = %q{Description}

  s.rubyforge_project = "dm-h2-adapter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
