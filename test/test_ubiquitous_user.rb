# -*- encoding: utf-8 -*-
# Copyright © 2011, José Pablo Fernández

require "helper"

class TestUbiquitousUser < Test::Unit::TestCase
  context "A controller and a mock user" do
    setup do
      @controller = Controller.new
      @user = mock("User")

      # Just to be sure we are starting from scratch
      assert_nil @controller.ubiquitous_user
    end

    should "create a new user object on current_user" do
      @user.expects(:new_record?).returns(true)
      User.expects(:new).returns(@user)

      user = @controller.current_user

      assert_equal @user, user
      assert_equal @user, @controller.ubiquitous_user
    end

    should "should return previous user object on current_user" do
      @user.expects(:new_record?).returns(true)
      @controller.ubiquitous_user = @user

      user = @controller.current_user

      assert_equal @user, user
    end

    should "find a user on current_user if there's a user_id on session" do
      user_id = 42
      @controller.session[:user_id] = user_id
      @user.expects(:new_record?).returns(true)
      User.expects(:find_by_id).with(user_id).returns(@user)

      user = @controller.current_user

      assert_equal @user, user
      assert_equal @user, @controller.ubiquitous_user
    end

    should "set the session user_id when saving a user" do
      user_id = 43
      User.expects(:new).returns(@user)
      @user.expects(:new_record?).returns(true)
      @user.expects(:save!)
      @user.expects(:id).returns(user_id)
      @user.expects(:after_save)

      user = @controller.current_user
      user.save!
      # save! should be calling after_save, but it isn't because it's a mock, so
      # let's call it manually
      user.after_save

      assert_equal @user, user
      assert_equal @user, @controller.ubiquitous_user
      assert_equal user_id, @controller.session[:user_id]
    end

    should "set user on current_user=" do
      user_id = 45
      user_name = "Alex"
      @user.expects(:id).returns(user_id)
      @user.expects(:name).returns(user_name)

      @controller.current_user = @user

      assert_equal @user, @controller.ubiquitous_user
      assert_equal user_id, @controller.session[:user_id]
      assert_equal user_name, @controller.session[:user_name]
    end

    should "unset user on current_user=(nil)" do
      @controller.current_user = nil

      assert_equal nil, @controller.ubiquitous_user
      assert_equal nil, @controller.session[:user_id]
      assert_equal nil, @controller.session[:user_name]
    end

    context "with custom config" do
      setup do
        @orig_config = UbiquitousUser::Config.clone
        UbiquitousUser::Config.user_model = :Person
        UbiquitousUser::Config.user_model_new = :new_person
        UbiquitousUser::Config.user_model_save = :save_person!
        UbiquitousUser::Config.user_model_name = :full_name
      end

      teardown do
        UbiquitousUser::Config.user_model = @orig_config.user_model
        UbiquitousUser::Config.user_model_new = @orig_config.user_model_new
        UbiquitousUser::Config.user_model_save = @orig_config.user_model_save
        UbiquitousUser::Config.user_model_name = @orig_config.user_model_name
      end

      should "create a new user object on #current_user" do
        @user.expects(:new_record?).returns(true)
        Person.expects(:new_person).returns(@user)
        assert_equal @user, @controller.current_user
        assert_equal @user, @controller.ubiquitous_user
      end

      should "set user on current_user=" do
        user_id = 45
        user_name = "Alex"
        @user.expects(:id).returns(user_id)
        @user.expects(:full_name).returns(user_name)

        @controller.current_user = @user

        assert_equal @user, @controller.ubiquitous_user
        assert_equal user_id, @controller.session[:user_id]
        assert_equal user_name, @controller.session[:user_name]
      end
    end
  end
end
