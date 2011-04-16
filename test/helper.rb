# -*- encoding: utf-8 -*-
# Copyright © 2011, José Pablo Fernández

require "rubygems"
require "test/unit"
require "shoulda"
require "mocha"

# Minimum set ActionController required to test ubiquitous_user
module ActionController
  class Base
    @@helpers = []

    def self.helper(h)
      @@helpers << h
    end
  end

  class RedirectBackError < Exception
  end
end

class Model
  attr_accessor :id
  @@after_save_methods = []

  def self.after_save(method)
    @@after_save_methods << method
  end

  def self.find_by_id(user_id)
    user = User.new
    user.id = user_id
    return user
  end

  def save
    self.id = object_id if id.nil?
    @@after_save_methods.each do |m|
      send(m)
    end
  end

  def save!
    save
  end

  def new_record?
    id.nil?
  end
end

# Default user model.
class User < Model
end

# An alternative user model.
class Person < Model
  class <<self
    alias_method :new_person, :new

    def new
      raise "This method shouldn't ever be called."
    end
  end
end

require "ubiquitous_user"

class Controller
  include UbiquitousUser::Usable

  # Simulate session and flash
  def initialize
    @session = {}
    @flash = {}
  end

  attr_accessor :session
  attr_accessor :flash

  # Allow access to @ubiquitous_user, only for testing purposes.
  attr_accessor :ubiquitous_user
end
