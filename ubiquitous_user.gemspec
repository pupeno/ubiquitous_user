# -*- encoding: utf-8 -*-
# Copyright © 2011, José Pablo Fernández

$:.unshift File.expand_path("../lib", __FILE__)
require "ubiquitous_user/version"

Gem::Specification.new do |s|
  s.name = "ubiquitous_user"
  s.version = UbiquitousUser::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["J. Pablo Fernández"]
  s.email = ["pupeno@pupeno.com"]
  s.homepage = "http://github.com/pupeno/ubiquitous_user"
  s.summary = "Helpers to get and retrieve users ubiquitously"
  s.description = "Create accounts for users right away, even when they are anonymous."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "ubiquitous_user"

  s.add_development_dependency "shoulda"
  s.add_development_dependency "rcov"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test}/*`.split("\n")

  #s.rdoc_options = ["--charset=UTF-8"]
end

