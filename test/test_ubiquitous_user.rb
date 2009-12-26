require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

module ActionController
  class Base
    @@helpers = []
    
    def self.helper(h)
      @@helpers << h
    end
  end
end

# Default user model.
class User
end

# An alternative user model.
class Person
end

require 'ubiquitous_user'

class Controller
  include Usable
  extend UsableClass
  
  def initialize
    @session = {}
  end
  
  attr_accessor :session
end

class TestUbiquitousUser < Test::Unit::TestCase
  context "A controller" do
    setup do
      @controller = Controller.new
    end
    
    should "create a new user object on #user" do
      # Mock user.
      user = mock("User")
      User.expects(:new).returns(user)
      
      assert_equal user, @controller.user
    end
    
    should "create a new user object on #user respecting the config" do
      # Save and change the user model.
      orig_config = UsableConfig.clone
      UsableConfig.user_model = :Person
      UsableConfig.user_model_new = :new_person
      
      # Mock user.
      user = mock("User")
      Person.expects(:new_person).returns(user)
      
      assert_equal user, @controller.user
      
      # Restore user model.
      UsableConfig.user_model = orig_config.user_model
      UsableConfig.user_model_new = orig_config.user_model_new
    end
  end
end
