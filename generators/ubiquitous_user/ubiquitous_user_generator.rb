# coding: utf-8
# Copyright 2010 J. Pablo Fernández

class UbiquitousUserGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'initializer.rb', 'config/initializers/ubiquitous_user.rb'
      
      m.readme 'INSTALL'
    end
  end
end