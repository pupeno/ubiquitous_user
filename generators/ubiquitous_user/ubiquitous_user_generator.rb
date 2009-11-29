class UbiquitousUserGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.file 'initializer.rb', 'config/initializers/ubiquitous_user.rb'
      
      m.readme 'INSTALL'
    end
  end
end