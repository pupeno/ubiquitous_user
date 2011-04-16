Ubiquitous User
===============

Many web applications required you to log in before being able to interact with
them; which poses a real barer of entry for new users. You need users to have
accounts for many tasks, but you don't need those accounts to be any more than
an id. No username, no password, no profile.

This library is an implementation of that. You add the UbiquitousUser::Usable
mixin to your ApplicationController and after that call user to get a 
current_user. When a new user is saved, it'll automatically store the id in the
session[:user_id] in the controller to mark this new user as the logged in user.

When a user logs in what you have to do is set the user, which is just doing

    current_user = userObject

The user model and how to authenticate is your responsibility; ubiquity_user
doesn't try solve those problem.

Since people just accessing your web site will have a user, people that is
already registered at your web site may have an anonymous user with activity in
it. You should try to merge it.

ubiquity_user is designed for and tested in Rails 3.X. It wight work on Rails
2.X but it might also require some fixes (which might be welcome). It also 
works fine with omni_auth.


Where?
------

The canonical places for this gem are:

* http://github.com/pupeno/ubiquitous_user
* http://rubygems.org/gems/ubiquitous_user
* http://rdoc.info/projects/pupeno/ubiquitous_user


How to use it
-------------

In your application_controller.rb be sure to add the mixin to
ApplicationController, like this:

    class ApplicationController < ActionController::Base
      include UbiquitousUser::Usable
    
      #...
    end

After that you can use user anywhere, for example:

    @item.recommender = current_user

or

    <%=h current_user.name %>

You can use current_user= in the controllers, for example:

    class SessionsController < ApplicationController
      def destroy
        self.current_user = nil
        # ...
      end
      
      def create
        # ...
        self.current_user = user
      end
      
      # ...
    end


The model
---------

Ubiquitous User expects you to have a model for your users called User
(configurable). You could create such a model with the following command:

    rails generate model User


Configuration
-------------

If your user model is not called User or the method to create a new one isn't
:new, then you can configure Ubiquity User to work with the alternatives:

    UbiquitousUser::Config::user_model = :User
    UbiquitousUser::Config::user_model_new = :new


API Documentation
-----------------

Up to date api documentation should be automatically generated on
http://rdoc.info/projects/pupeno/ubiquitous_user


Note on patches and pull requests
---------------------------------
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2009, 2010, 2011 José Pablo Fernández. See LICENSE for details.
