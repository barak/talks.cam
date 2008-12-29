# Include your application configuration below

require 'icalendar_extensions'

begin 
  require 'RMagick'
rescue LoadError
  require_gem 'RMagick'
end

RAVEN_SETTINGS = { 
  # :raven_url 		=> 'https://demo.raven.cam.ac.uk/auth/authenticate.html',  
   :raven_url 		=> 'https://raven.cam.ac.uk/auth/authenticate.html',
  :raven_version => '1',
  :max_skew 		=> 90, # seconds
  :public_key_files => { 2 => File.join(File.dirname(__FILE__), 'pubkey2.txt') },
#  :public_key_files => { 901 => File.join(File.dirname(__FILE__), 'pubkey901.txt') },
  :description 	=> 'the talks.cam website',
  :message 		=> 'we wish to track who makes what changes',
  :aauth 			=> [],
  :iact 			=> "",
  :match_response_and_request => true,
  :fail 			=> "",
  }

# Configure the exception notification plugin
ExceptionNotifier.exception_recipients = %w( BUGS@talks.cam )
ExceptionNotifier.sender_address =%( "talks.cam" <BUGS_SENDER@talks.cam> )

# Monkey patch ActionMailer to force a return-path to be inserted
class ActionMailer::Base
  def perform_delivery_sendmail(mail)
#    IO.popen("/usr/sbin/sendmail -i -t","w+") do |sm|
    IO.popen("/usr/sbin/sendmail -i -t -fBUGS_ENVELOPE@talks.cam","w+") do |sm|
      sm.print(mail.encoded.gsub(/\r/, ''))
      sm.flush
    end
  end
end