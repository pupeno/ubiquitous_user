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
  
  # Simulate session
  def initialize
    @session = {}
  end
  attr_accessor :session
  
  # Allow access to @ubiquitous_user, only for testing purposes.
  attr_accessor :ubiquitous_user
end

class TestUbiquitousUser < Test::Unit::TestCase
  context "A controller and a mock user" do
    setup do
      @controller = Controller.new
      @user = mock("User")
      
      # Just to be sure we are starting from scratch
      assert_nil @controller.ubiquitous_user
    end
    
    should "create a new user object on #user" do
      User.expects(:new).returns(@user)
      assert_equal @user, @controller.user
      assert_equal @user, @controller.ubiquitous_user
    end
    
    should "should return previous user object on #user" do
      @controller.ubiquitous_user = @user
      assert_equal @user, @controller.user
    end
    
    should "find a user on #user if there's a user_id on session" do
      user_id = 42
      @controller.session[:user_id] = user_id
      User.expects(:find).with(user_id).returns(@user)
      assert_equal @user, @controller.user
      assert_equal @user, @controller.ubiquitous_user
    end
    
    should "create a new user object on #user respecting the config" do
      # Save and change the user model.
      orig_config = UsableConfig.clone
      UsableConfig.user_model = :Person
      UsableConfig.user_model_new = :new_person
      
      # Mock user.
      Person.expects(:new_person).returns(@user)
      
      assert_equal @user, @controller.user
      assert_equal @user, @controller.ubiquitous_user
      
      # Restore user model.
      UsableConfig.user_model = orig_config.user_model
      UsableConfig.user_model_new = orig_config.user_model_new
    end
  end
end
