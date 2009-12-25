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
  def user(options = {:save => false})
    # Find the user in the database if session[:user_id] is defined and @ubiquitous_user is not.
    @ubiquitous_user = UsableConfig::user_model_class.find(session[:user_id]) if session[:user_id] != nil and @ubiquitous_user == nil
    
    # Create a new user object if @ubiquitous_user is not defined.
    @ubiquitous_user = UsableConfig::user_model_class.send(UsableConfig::user_model_new)  if @ubiquitous_user == nil
    
    # If the object is new and we are asked to save, do it.
    if @ubiquitous_user.new_record? and options[:save]
      # Save the user in the database and set the session user_id for latter.
      @ubiquitous_user.send(UsableConfig::user_model_save)
      session[:user_id] = @ubiquitous_user.id
    end
    
    return @ubiquitous_user
  end
  
  # Helper method to get a user that for sure exists on the database.
  def user!
    return user(:save => true)
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
  
  def is_user_logged_in
    UsableConfig::user_model_class.find_by_id(session[:user_id]) and session[:user_name] != nil
  end
  
  def authorize
    unless is_user_logged_in
      flash[:notice] = "Please log in."
      redirect_to new_session_url
    end
  end
  
  def self.authorize(message = nil, key = :notice)
    if message == nil
      authorize("Please log in")
    else
      Proc.new do |controller|
        unless controller.is_user_logged_in
          controller.send(:flash)[key] = message
          controller.send(:redirect_to, controller.send(:new_session_url))
        end
      end
    end
  end
end