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
end
