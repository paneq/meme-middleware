# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "meme-middleware/version"

Gem::Specification.new do |s|
  s.name        = "meme-middleware"
  s.version     = Meme::Middleware::VERSION
  s.authors     = ["Robert Pankowecki"]
  s.email       = ["robert.pankowecki@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Find meme references in your pages and convert them to images}
  s.description = s.summary

  s.rubyforge_project = "meme-middleware"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rack"
  # s.add_runtime_dependency "rest-client"
end
