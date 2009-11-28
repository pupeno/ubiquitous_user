module UsableHelpers
  # Helper method to get the current user. It will always return a user but the
  # user may not be in the database. If options[:create] is true, then the user
  # will be in the database (although it may be a ghost user).
  def user(options = {:create => false})
    # If we already have a user object, return that.
    return @ubiquitous_user if @ubiquitous_user != nil
    
    # Try to find the user in the database if session[:user_id] is defined.
    @ubiquitous_user = User.find(session[:user_id]) if session[:user_id] != nil
    return @ubiquitous_user if @ubiquitous_user != nil
    
    # Create a new user object.
    @ubiquitous_user = User.new()
    if options[:create]
      # Save the user in the database and set the session user_id for latter.
      # TODO use UsableConfig::UserModelSave
      @ubiquitous_user.save_bypassing_non_essential_validation
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
    session[:user_id] = u and u.id or nil
    session[:user_name] = u and u.name or nil
    user
  end
  
  def authorize
    unless User.find_by_id(session[:user_id]) and session[:user_name] != nil
      flash[:notice] = "Please log in."
      redirect_to new_session_url
    end
  end
end