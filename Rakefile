# -*- encoding: utf-8 -*-
# Copyright © 2011, José Pablo Fernández

$:.unshift File.expand_path("../lib", __FILE__)
require "ubiquitous_user/version"

require "bundler"
Bundler::GemHelper.install_tasks

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/**/test_*.rb"
  test.verbose = true
end
task :default => :test

require "rcov/rcovtask"
Rcov::RcovTask.new do |test|
  test.libs << "test"
  test.pattern = "test/**/test_*.rb"
  test.verbose = true
end

require "rake/rdoctask"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "Ubiquitous User #{UbiquitousUser::VERSION}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("LICENSE")
  rdoc.rdoc_files.include("lib/**/*.rb")
end
