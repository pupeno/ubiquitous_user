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

# Default user model.
class User
end

# An alternative user model.
class Person
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
