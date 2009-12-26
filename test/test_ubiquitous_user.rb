require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'ruby-debug'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

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

require 'ubiquitous_user'

class Controller
  include Usable
  extend UsableClass
  
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

class TestUbiquitousUser < Test::Unit::TestCase
  context "A controller and a mock user" do
    setup do
      @controller = Controller.new
      @user = mock("User")
      
      # Just to be sure we are starting from scratch
      assert_nil @controller.ubiquitous_user
    end
    
    should "create a new user object on Controller#user" do
      User.expects(:new).returns(@user)
      
      user = @controller.user
      
      assert_equal @user, user
      assert_equal @user, @controller.ubiquitous_user
    end
    
    should "should return previous user object on Controller#user" do
      @controller.ubiquitous_user = @user
      
      user = @controller.user
      
      assert_equal @user, user
    end
    
    should "find a user on Controller#user if there's a user_id on session" do
      user_id = 42
      @controller.session[:user_id] = user_id
      User.expects(:find_by_id).with(user_id).returns(@user)
      
      user = @controller.user
      
      assert_equal @user, user
      assert_equal @user, @controller.ubiquitous_user
    end
    
    should "save a new user when requested on Controller#user" do
      user_id = 43
      User.expects(:new).returns(@user)
      @user.expects(:new_record?).returns(true)
      @user.expects(:save!)
      @user.expects(:id).returns(user_id)
      
      user = @controller.user!
      
      assert_equal @user, user
      assert_equal @user, @controller.ubiquitous_user
      assert_equal user_id, @controller.session[:user_id]
    end
    
    should "not save an existing user even when requested on Controller#user" do
      user_id = 44
      @controller.session[:user_id] = user_id
      User.expects(:find_by_id).with(user_id).returns(@user)
      @user.expects(:new_record?).returns(false)
      
      user = @controller.user!
      
      assert_equal @user, user
      assert_equal @user, @controller.ubiquitous_user
    end
    
    should "set user on Controller#user=" do
      user_id = 45
      user_name = "Alex"
      @user.expects(:id).returns(user_id)
      @user.expects(:name).returns(user_name)
      
      @controller.user = @user
      
      assert_equal @user, @controller.ubiquitous_user
      assert_equal user_id, @controller.session[:user_id]
      assert_equal user_name, @controller.session[:user_name]
    end
    
    should "unset user on Controller#user=(nil)" do
      @controller.user = nil
      
      assert_equal nil, @controller.ubiquitous_user
      assert_equal nil, @controller.session[:user_id]
      assert_equal nil, @controller.session[:user_name]
    end
    
    should "say no user is logged in when none is on Controller#user_logged_in?" do
      user_logged_in = @controller.user_logged_in?
      
      assert !user_logged_in
    end
    
    should "say no user is logged in when an anonymously registered user is in on Controller#user_logged_in?" do
      user_id = 46
      @controller.session[:user_id] = user_id
      User.expects(:find_by_id).with(user_id).returns(@user)
      
      user_logged_in = @controller.user_logged_in?
      
      assert !user_logged_in
    end
    
    should "say a user is logged in when it is on Controller#user_logged_in?" do
      user_id = 46
      user_name = "Brad"
      @controller.session[:user_id] = user_id
      @controller.session[:user_name] = user_name
      User.expects(:find_by_id).with(user_id).returns(@user)
      
      user_logged_in = @controller.user_logged_in?
      
      assert user_logged_in
    end
    
    should "redirect back with a flash message when user not logged in on Controller.authorize" do
      msg = "Log in you user!"
      key = :error
      
      authorize = Controller.send(:authorize, msg, key)
      
      assert authorize.instance_of? Proc
      
      @controller.expects(:redirect_to).with(:back)
      
      authorize.call(@controller)
      assert_equal msg, @controller.flash[key]
    end
    
    should "redirect to new_session_url with a flash message when user not logged in and there's no :back on Controller.authorize" do
      msg = "Log in you user!"
      key = :error
      
      authorize = Controller.send(:authorize, msg, key)
      
      assert authorize.instance_of? Proc
      
      new_session_url = "/login"
      @controller.expects(:redirect_to).with(:back).raises(ActionController::RedirectBackError)
      @controller.expects(:new_session_url).returns(new_session_url)
      @controller.expects(:redirect_to).with(new_session_url)
      
      authorize.call(@controller)
      assert_equal msg, @controller.flash[key]
    end
    
    should "redirect back with a flash message when user not logged in on Controller#authorize" do
      @controller.expects(:redirect_to).with(:back)
      
      @controller.authorize
      assert_equal "Please log in.", @controller.flash[:warning]
    end
    
    context "with custom usable config" do
      setup do
        @orig_config = UsableConfig.clone
        UsableConfig.user_model = :Person
        UsableConfig.user_model_new = :new_person
        UsableConfig.user_model_save = :save_person!
        UsableConfig.user_model_name = :full_name
      end
      
      teardown do
        UsableConfig.user_model = @orig_config.user_model
        UsableConfig.user_model_new = @orig_config.user_model_new
        UsableConfig.user_model_save = @orig_config.user_model_save
        UsableConfig.user_model_name = @orig_config.user_model_name
      end
      
      should "create a new user object on #user" do
        Person.expects(:new_person).returns(@user)
        assert_equal @user, @controller.user
        assert_equal @user, @controller.ubiquitous_user
      end
      
      should "save a new user when requested on #user" do
        user_id = 43
        Person.expects(:new_person).returns(@user)
        @user.expects(:new_record?).returns(true)
        @user.expects(:save_person!)
        @user.expects(:id).returns(user_id)
        assert_equal @user, @controller.user!
        assert_equal @user, @controller.ubiquitous_user
        assert_equal user_id, @controller.session[:user_id]
      end
      
      should "set user on Controller#user=" do
        user_id = 45
        user_name = "Alex"
        @user.expects(:id).returns(user_id)
        @user.expects(:full_name).returns(user_name)
        
        @controller.user = @user
        
        assert_equal @user, @controller.ubiquitous_user
        assert_equal user_id, @controller.session[:user_id]
        assert_equal user_name, @controller.session[:user_name]
      end
      
      should "say a user is logged in when it is on #user_logged_in?" do
        user_id = 46
        user_name = "Brad"
        @controller.session[:user_id] = user_id
        @controller.session[:user_name] = user_name
        Person.expects(:find_by_id).with(user_id).returns(@user)
        
        user_logged_in = @controller.user_logged_in?
        
        assert user_logged_in
      end
    end
  end
end
