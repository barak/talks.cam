require "#{File.dirname(__FILE__)}/../test_helper"

class TalkCreateTest < ActionController::IntegrationTest
    fixtures :users, :lists, :talks

    def test_speaker
      new_session do |vic|
        vic.logs_in 'vic@talks.cam'
        User.current = vic.user
        #vic.create_talk lists(:vicslist)
        # Unfinished
      end
    end
    
    private

    module LoginDSL
     
     attr_accessor :user
     
     def create_talk( list )
        get talk_url(:id => list.id, :action => 'create')
        assert_response :redirect
        follow_redirect!
        assert_template 'talks/edit'
     end
     
     def email_for( address )
        ActionMailer::Base.deliveries.find_all { |mail| mail.to.include? address }
     end
     
     def delete_email_for( address )
        ActionMailer::Base.deliveries.delete_if { |mail| mail.to.include? address }
     end
     
     def gets_an_email_with_login_details( address )
       assert_equal 1, email_for(address).find_all{ |mail| mail.subject == 'Your login details at talks.cam' }.size
     end
     
     def logs_in( email = nil, return_url = nil )
        @user = User.find_by_email email
        params = { :email => user.email, :password => user.password }
        params[:return_url] = return_url if return_url
        post login_url(:action=>'not_raven_login'), params
     end
     
     def logs_out
        get login_url(:action => 'logout')
        assert_response :success
        assert_template 'login/logout'
     end
      
      def method_missing(method, *args)
        raise NoMethodError.new("no user: #{method} #{args.inspect}") unless user
        raise NoMethodError.new("no method: #{method} #{args.inspect}") unless user.respond_to?(method)
        user.send method, *args
      end
           
    end

  def new_session
    open_session do |sess|
       sess.extend(LoginDSL)
       yield sess if block_given?
    end
  end
  
end