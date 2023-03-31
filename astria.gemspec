# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'astria/version'

Gem::Specification.new do |s|
  s.name        = 'astria'
  s.version     = Astria::VERSION
  s.authors     = ['ghostboo']
  s.email       = ['rhiza@chunky.city']
  s.homepage    = 'https://github.com/chunky-metro/astria-ruby'
  s.summary     = 'The Astria API client for Ruby'
  s.description = 'The Astria API client for Ruby.'

  s.required_ruby_version = ">= 3.0.0"

  s.require_paths    = ['lib']
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extra_rdoc_files = %w( LICENSE.txt )

  s.add_dependency 'http.rb'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'webmock'
end
