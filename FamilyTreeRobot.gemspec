# -*- encoding: utf-8 -*-
$:.push File.expand_path(".", __FILE__)
require "./familytree/version"

Gem::Specification.new do |s|
  s.name        = "family_tree_robot"
  s.version     = FamilyTree::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jim Lindstrom"]
  s.email       = ["jim.lindstrom@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Robot for locally mirroring changes to people on a Mediawiki-based family tree site.}
  s.description = %q{Robot for locally mirroring changes to people on a Mediawiki-based family tree site.}

  s.rubyforge_project = "family_tree_robot"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'mediawiki_robot'
  s.add_dependency 'pg'
  s.add_dependency 'rspec-core'
  s.add_dependency 'rspec-mocks'
  s.add_dependency 'rspec-expectations'
end
