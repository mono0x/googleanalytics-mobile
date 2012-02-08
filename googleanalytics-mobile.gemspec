# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "googleanalytics/mobile/version"

Gem::Specification.new do |s|
  s.name        = "googleanalytics-mobile"
  s.version     = GoogleAnalytics::Mobile::VERSION
  s.authors     = ["mono"]
  s.email       = ["mono@monoweb.info"]
  s.homepage    = "http://blog.monoweb.info/"
  s.summary     = %q{A Google Analytics tracker for feature phones}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency "rack"
  s.add_runtime_dependency "sinatra"
end
