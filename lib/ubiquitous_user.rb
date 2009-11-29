module UsableConfig
  @user_model = :User
  @user_model_new = :new
  @user_model_save = :save
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

  def user_model_class  # :nodoc:
    Object.const_get(user_model)
  end
  module_function :user_model_class
end

module UsableHelpers
  # Helper method to get the current user. It will always return a user but the
  # user may not be in the database. If options[:create] is true, then the user
  # will be in the database (although it may be a ghost user).
  def user(options = {:create => false})
    # If we already have a user object, return that.
    return @ubiquitous_user if @ubiquitous_user != nil
    
    # Try to find the user in the database if session[:user_id] is defined.
    @ubiquitous_user = UsableConfig::user_model_class.find(session[:user_id]) if session[:user_id] != nil
    return @ubiquitous_user if @ubiquitous_user != nil
    
    # Create a new user object.
    @ubiquitous_user = UsableConfig::user_model_class.send(UsableConfig::user_model_new)
    if options[:create]
      # Save the user in the database and set the session user_id for latter.
      @ubiquitous_user.send(UsableConfig::user_model_save)
      session[:user_id] = @ubiquitous_user.id
    end
    return @ubiquitous_user
  end
  
  # Helper method to get a user that for sure exists on the database.
  def user!
    return user(:create => true)
  end
end

ActionController::Base.class_eval do
  helper UsableHelpers
end

module Usable
  include UsableHelpers
  
  def user=(u)
    session[:user_id] = u != nil ? u.id : nil
    session[:user_name] = u != nil ? u.send(UsableConfig::user_model_name) : nil
    user
  end
  
  def authorize
    unless UsableConfig::user_model_class.find_by_id(session[:user_id]) and session[:user_name] != nil
      flash[:notice] = "Please log in."
      redirect_to new_session_url
    end
  end
end