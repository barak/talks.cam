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
      when ::SystemExit
        logger.error "SystemExit caught in ApplicationController: #{exception.message}\n" + exception.backtrace.join("\n")
        # No point trying to render anything, we're being killed off
      when ::ActionView::TemplateError
        if exception.message.match('SystemExit') != nil
          logger.error "TemplateError SystemExit caught in ApplicationController: #{exception.message}\n" + exception.backtrace.join("\n")
          # No point trying to render anything, we're being killed off
        elsif exception.backtrace.join('').match('exit_now_handler') != nil
          logger.error "TemplateError exit caught in ApplicationController: #{exception.message}\n" + exception.backtrace.join("\n")
          # No point trying to render anything, we're being killed off
        else
          return super
        end
      else
        return super
    end
  end
  
end
