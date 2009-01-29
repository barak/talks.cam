module CheckForUser
  
  def self.append_features(base)
    super
    base.class_eval do # This gets executed as if it was in the class definition
      before_filter :set_user
    end
  end
  
  private

  def ensure_user_is_logged_in
    return true if User.current
    redirect_to_login
  end
  
  def redirect_to_login
    session["return_to"] = request.request_uri
    flash[:warning] = login_message
    redirect_to login_url
    return false
  end
    
  def set_user
    User.current = user_from_session || user_from_http_header
  end
  
  def user_from_session
    return nil unless session[:user_id]
    User.find( session[:user_id] )    
  end
  
  def user_from_http_header
    return nil unless authorization(request)
    return nil if authorization(request).empty?
    User.find_by_email_and_password(*email_and_password(request))
  end
    
  def email_and_password(request)
    Base64.decode64(credentials(request)).split(/:/, 2)
  end  
  
  def credentials(request)
    authorization(request).split.last
  end
  
  def authorization(request)
    request.env['HTTP_AUTHORIZATION']   ||
    request.env['X-HTTP_AUTHORIZATION'] ||
    request.env['X_HTTP_AUTHORIZATION'] ||
    request.env['REDIRECT_X_HTTP_AUTHORIZATION']
  end
  
  # Can be overridden in individual controllers
  def login_message
    "You need to be logged in to carry this out.<br/>If you don't have an account, feel free to create one."
  end
end