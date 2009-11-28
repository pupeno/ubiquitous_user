
module Usable
  UserModel = User
  UserModelSave = :save
end

module UsableHelpers
  Users = {}
  
  # Helper method to get the current user. It will always return a user but the
  # user may not be in the database. If options[:create] is true, then the user
  # will be in the database (although it may be a ghost user).
  def user(options = {:create => false})
    # If we already have a user object, return that.
    return Users[object_id] if Users[object_id] != nil
    
    # Try to find the user in the database if session[:user_id] is defined.
    Users[object_id] = User.find(session[:user_id]) if session[:user_id] != nil
    return Users[object_id] if Users[object_id] != nil
    
    # Create a new user object.
    Users[object_id] = Usable::UserModel.new()
    if options[:create]
      # Save the user in the database and set the session user_id for latter.
      # TODO use Usable::UserModelSave
      Users[object_id].save_bypassing_non_essential_validation
      session[:user_id] = Users[object_id].id
    end
    return Users[object_id]
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
  
  def user=(user)
    session[:user_id] = user and user.id or nil
    session[:user_name] = user and user.name or nil
    user
  end
  
  def authorize
    unless UserModel.find_by_id(session[:user_id]) and session[:user_name] != nil
      flash[:notice] = "Please log in."
      redirect_to new_session_url
    end
  end
end