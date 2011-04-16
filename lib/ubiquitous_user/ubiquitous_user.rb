# -*- encoding: utf-8 -*-
# Copyright © 2011, José Pablo Fernández

module UbiquitousUser
  module Config
    @user_model = :User
    @user_model_new = :new
    @user_model_save = :save!
    @user_model_name = :name

    # Class that defines the user model.
    attr_accessor :user_model
    module_function :user_model, :user_model=
    # Method used to create a new user, of class user_model
    attr_accessor :user_model_new
    module_function :user_model_new, :user_model_new=
    # Method used to save the user.
    attr_accessor :user_model_save
    module_function :user_model_save, :user_model_save=
    # Method used to get the name of the user.
    attr_accessor :user_model_name
    module_function :user_model_name, :user_model_name=

    def user_model_class # :nodoc:
      Object.const_get(user_model)
    end

    module_function :user_model_class
  end

  module Helpers
    # Helper method to get the current user. It will always return a user but the
    # user may not be in the database. If options[:create] is true, then the user
    # will be in the database (although it may be a ghost user).
    def current_user
      # Find the user in the database if session[:user_id] is defined and @ubiquitous_user is not.
      @ubiquitous_user = UbiquitousUser::Config::user_model_class.find_by_id(session[:user_id]) if session[:user_id] != nil and @ubiquitous_user == nil

      # Create a new user object if @ubiquitous_user is not defined.
      @ubiquitous_user = UbiquitousUser::Config::user_model_class.send(UbiquitousUser::Config::user_model_new) if @ubiquitous_user == nil

      # If the object is new, let's get ready to mark the user as logged in when saving.
      if @ubiquitous_user.new_record? or @ubiquitous_user.id != session[:user_id]
        controller = self
        # Read more about this technique on http://stackoverflow.com/questions/2495550/define-a-method-that-is-a-closure-in-ruby
        klass = class << @ubiquitous_user;
          self;
        end
        klass.send(:define_method, :after_save) do
          super
          controller.session[:user_id] = self.id
        end
      end

      return @ubiquitous_user
    end
  end

  # TODO: should this really be top level?
  ::ActionController::Base.class_eval do
    helper UbiquitousUser::Helpers
  end

  module Usable
    include UbiquitousUser::Helpers

    def current_user=(new_user)
      session[:user_id] = new_user != nil ? new_user.id : nil
      session[:user_name] = new_user != nil ? new_user.send(UbiquitousUser::Config::user_model_name) : nil
      @ubiquitous_user = new_user
    end
  end
end

