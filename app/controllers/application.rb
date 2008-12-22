# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  
  include ExceptionNotifiable # E-mails exceptions and errors to the address set in config/environment.rb
  include CheckForUser # On each request, checks for user information in session or in header and sets User.current

  private

  # If someone types in a url that rails doesn't recognise, then returns a 404 rather than an
  # application error
  def rescue_action_in_public(exception)
    case exception
      when ::ActionController::RoutingError, ::ActionController::MissingTemplate
        render_404
      else
        return super
    end
  end
  
end
