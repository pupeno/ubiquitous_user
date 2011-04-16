# -*- encoding: utf-8 -*-
# Copyright © 2011, José Pablo Fernández

require "helper"

class TestUbiquitousUser < Test::Unit::TestCase
  context "A controller" do
    setup do
      @controller = Controller.new
      # Just to be sure we are starting from scratch
      assert_nil @controller.ubiquitous_user
      assert_nil @controller.session[:user_id]
    end

    should "create a new user object on current_user" do
      user = @controller.current_user
      assert_equal User, user.class
      assert_equal @controller.ubiquitous_user, user
      assert user.new_record?
    end

    should "find a user on current_user if there's a user_id on session" do
      @controller.session[:user_id] = 42
      user = @controller.current_user
      assert_equal @controller.session[:user_id], user.id
    end

    should "set the session user_id when saving a user" do
      user = @controller.current_user
      user.save!
      assert_not_nil user.id
      assert_not_nil @controller.session[:user_id]
      assert_equal user.id, @controller.session[:user_id]
    end

    should "unset user on current_user=(nil)" do
      @controller.current_user = nil

      assert_equal nil, @controller.ubiquitous_user
      assert_equal nil, @controller.session[:user_id]
    end

    context "and a user" do
      setup do
        @user = User.new
        assert_nil @user.id
      end

      should "should return previous user object on current_user" do
        @controller.ubiquitous_user = @user
        assert_equal @user, @controller.current_user
        assert_nil @controller.session[:user_id]
      end

      context "that is saved" do
        setup do
          @user.save!
          assert_not_nil @user.id
        end

        should "set user on current_user=" do
          @controller.current_user = @user

          assert_equal @user, @controller.ubiquitous_user
          assert_equal @user.id, @controller.session[:user_id]
        end
      end
    end

    context "with custom config" do
      setup do
        @orig_config = UbiquitousUser::Config.clone
        UbiquitousUser::Config.user_model = :Person
        UbiquitousUser::Config.user_model_new = :new_person
      end

      teardown do
        UbiquitousUser::Config.user_model = @orig_config.user_model
        UbiquitousUser::Config.user_model_new = @orig_config.user_model_new
      end

      should "create a new user object on #current_user" do
        person = @controller.current_user
        assert_equal Person, person.class
      end
    end
  end
end
