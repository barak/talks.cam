require 'openssl'
require 'webrick'
require 'base64'

class LoginController < ApplicationController

 filter_parameter_logging :password

 @@raven_settings = RAVEN_SETTINGS
  
  cattr_accessor :raven_settings
  before_filter :store_return_url_in_session

  ERROR = WEBrick::HTTPStatus::Unauthorized

	RAVEN_ERRORS = {
		520 => "Incorrect raven version",
		540 => "Required user interaction did not take place",		
		550 => "Message has incorrect time",
		560 => "Signature not verified",
		570 => "Incorrect return url" }

	def initialize
	  @publickey = {}
		raven_settings[:public_key_files].each { |id,filename| load_public_key( id, filename) }
	end
	
	def store_return_url_in_session
    session["return_to"] = params[:return_url] if (params[:return_url] && params[:return_url] != '/login/logout')
	end
	
	def logout
	 User.current = nil
	 session[:user_id ] = nil
	 session["return_to"] = nil
	 flash[:confirm] = "You have been logged out."
	end
	
  def not_raven_login
    user = User.find_by_email params[:email]
    if user
      if user.password && params[:password] == user.password
        session[:user_id ] = user.id
        post_login_actions
    	else
  	    flash[:login_error] = "Password not correct"
  	    @email = user.email
  	    render :action => 'index'
  	  end
    else
      flash[:login_error] = "I have no record of this email"
      render :action => 'index'
    end
  end
  
  def go_to_raven
		#Store a random number in params so we can match this request to later responses
		raven_params = session[:request_id] = rand( 999999 ).to_s
		
		redirect_to_url "#{raven_settings[:raven_url]}?" <<
		"ver=#{escape(raven_settings[:raven_version])};" <<
		"url=#{escape( url_for( :action => 'from_raven' ))};" <<
		"desc=#{escape(raven_settings[:description])};" <<
		"msg=#{escape(raven_settings[:message])};" <<
		"iact=#{escape(raven_settings[:iact])};" <<
		"aauth=#{escape(raven_settings[:aauth].join(","))};" <<
		"params=#{escape(raven_params)};" <<
		"fail=#{escape(raven_settings[:fail])}"
	end
  
	def from_raven
		wls_response = params['WLS-Response'].to_s
		return nil if wls_response == ""
		ver, status, msg, issue, id, url, principal, auth, sso, life, params, kid, sig = wls_response.split('!')

		#Check the protocol version
		error(520) unless ver == raven_settings[:raven_version]

		#Check the url
		error(570, url, raven_settings[:return_url] ) unless url == url_for( :action => 'from_raven' )

		#Check the time skew
		skew = timeforRFC3339( issue ) - Time.now
		error(550) unless skew.abs < raven_settings[:max_skew]

		#Optionally check that interaction with the user took place
		error(540) if ( raven_settings[:iact] == 'yes' &&  auth == "" )

		#Optionally check that this response matches a request
		if @match_response_and_request
			error(570,"Mismatch request and response id") unless session.request_id == CGI.unescape( params )
		end
    
		#If status is 410, user pressed Cancel on Raven page - redirect to home page
		if status.to_i == 410
		  redirect_to(home_url)
		  return
		end

		#If we got here, and status is 200, then yield the principal
		error(status.to_i, msg) unless status.to_i == 200
		
		#Check that the Key Id is one we currently accept
		publickey = @publickey[ unescape( kid ).to_i ]
		error(560,'key not found', unescape( kid )) unless publickey	

		#Check the signature
		length_to_drop = -(sig.length + kid.length + 3)
		signedbit = wls_response[ 0 .. length_to_drop]
		error(560,'signature incorrect') unless publickey.verify( OpenSSL::Digest::SHA1.new, Base64.decode64(sig.tr('-._','+/=')), signedbit)

		#Signature ok. So store this person in a session so don't need to repeatedly authenticate.
		session[:user_id] = User.find_or_create_by_crsid(principal).id
		post_login_actions
	end

  def send_password
    @user = User.find_by_email params[:email]
    if @user
      @user.send_password
      render :action => 'password_sent'
    else
      flash[:error] = "I'm sorry, but #{params[:email]} is not listed on this system. (note that is is case sensitive)"
      render :action => 'lost_password'
    end
  end
  
  def new_user
    @user = User.find session[:user_id]
  end
  
  def do_new_user
    user = User.find session[:user_id]
    user.name = params[:name] if params[:name]
    user.affiliation = params[:affiliation] if params[:affiliation]
    user.save
    user.subscribe_to_list( user.personal_list ) if params[:send_email] == '1'
    user.update_attribute :last_login, Time.now
    return_to_original_url
  end
  
  def return_to_original_url
    redirect_to original_url
  end
  
  private
  
  def post_login_actions
    user = User.find(session[:user_id])
    if user.needs_an_edit?
      redirect_to user_url(:action => 'edit',:id => user )
    else
 		  return_to_original_url
 		end
	  flash[:confirm] = "You have been logged in."
	  user.update_attribute :last_login, Time.now
  end
  
  def original_url
    original_url = session["return_to"] || list_url(:id => User.find(session[:user_id]).personal_list )
    session["return_to"] = nil
    return original_url
  end
  
  def error( raven_code, *variables )
		raise ERROR.new( "Raven error #{raven_code}: #{RAVEN_ERRORS[raven_code]} : #{variables.join(' ')}" )
	end

	def load_public_key( id, filename )
		@publickey[ id ] = OpenSSL::PKey::RSA.new( IO.readlines( filename ).to_s )
	end

	# Takes a string with a time encoded according to rfc3339 (e.g. 20040114T123103Z) and returns a Time object.
	def timeforRFC3339( rfc3339 )
		year = rfc3339[ 0..3 ].to_i
		month = rfc3339[ 4..5 ].to_i
		day = rfc3339[ 6..7 ].to_i
		hour = rfc3339[ 9..10 ].to_i
		minute = rfc3339[ 11..12 ].to_i
		second = rfc3339[ 13..14 ].to_i
		return Time.gm( year, month, day, hour, minute, second)
	end	

	# Borrowed from CGI class to encode message to pass to raven
	def escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')	
	end

	# Borrowed from CGI class to decode messages from raven
	def unescape(string)
    string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
      [$1.delete('%')].pack('H*')
    end
	end
end
