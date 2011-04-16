# -*- encoding: utf-8 -*-
# Copyright © 2011, José Pablo Fernández

module UbiquitousUser
  module Config
    @user_model = :User
    @user_model_new = :new

    # Class that defines the user model.
    attr_accessor :user_model
    module_function :user_model, :user_model=
    # Method used to create a new user, of class user_model
    attr_accessor :user_model_new
    module_function :user_model_new, :user_model_new=

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
        if !@ubiquitous_user.respond_to? :mark_user_as_logged_in_in_the_session
          UbiquitousUser::Config::user_model_class.class_eval do
            after_save :mark_user_as_logged_in_in_the_session

            def mark_user_as_logged_in_in_the_session
              if !@session_reference_by_ubiquitous_user.nil?
                @session_reference_by_ubiquitous_user[:user_id] = id
              end
            end
          end
        end
        @ubiquitous_user.instance_variable_set "@session_reference_by_ubiquitous_user", self.session
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
      @ubiquitous_user = new_user
    end
  end
end

