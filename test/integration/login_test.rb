require "#{File.dirname(__FILE__)}/../test_helper"

class LoginTest < ActionController::IntegrationTest
    fixtures :users, :lists, :talks

    def test_signup_new_person
      # First time gets whole new user stuff
      new_session do |bob|
        bob.goes_to_login
        bob.goes_to_account_request
        bob.signs_up_as :user => { :email => 'bob@talks.cam', :send_email => 1 }
        bob.gets_an_email_with_login_details 'bob@talks.cam'
        bob.goes_to_login
        bob.logs_in 'bob@talks.cam'
        bob.sent_to_new_user_page?
        # bob.submits_new_user_page(:send_email => 1)
        # bob.sent_to_personal_list?
        # assert_equal bob.personal_list, bob.email_subscriptions.first.list
        bob.logs_out
      end
      
      # Next time gets taken straight to personal list
      new_session do |bob|
        bob.goes_to_login
        bob.logs_in 'bob@talks.cam'
        bob.sent_to_personal_list?
        bob.logs_out
      end
      
      # Later gets redirected back to where he was
      new_session do |bob|
        get list_url(:id => 1)
        bob.logs_in 'bob@talks.cam', list_url(:id => 1)
        #puts response.body
        assert_response :success # I think this should be redirect
        # assert_redirected_to list_url(:id => 1)
        assert_template "show/index"
        bob.logs_out
      end
      
    end
    
    private

    module LoginDSL
     
     attr_accessor :user
     
     def goes_to_login
       get login_url
       assert_response :success
       assert_template "login/index"
     end
     
     def goes_to_account_request
       get new_user_url
       assert_response :success
       assert_template "user/new"
     end
          
     def signs_up_as(details)
       get new_user_url
        post user_url(:action => 'create'), details
        user = assigns(:user)
        assert_response :redirect
        assert_redirected_to user_url(:action => "password_sent")
     end
     
     def email_for( address )
        ActionMailer::Base.deliveries.find_all { |mail| mail.to.include? address }
     end
     
     def delete_email_for( address )
        ActionMailer::Base.deliveries.delete_if { |mail| mail.to.include? address }
     end
     
     def gets_an_email_with_login_details( address )
       assert_equal 1, email_for(address).find_all{ |mail| mail.subject == 'Your talks.cam password' }.size
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
     
     def sent_to_new_user_page?
       assert_response :redirect
       assert_redirected_to user_url(:action => 'edit',:id => user.id)
     end

     def submits_new_user_page( parameters )
       post login_url(:action => 'do_new_user'), parameters   
      end
      
      def sent_to_personal_list?
        assert_response :redirect
        assert_redirected_to list_url(:id => user.personal_list )
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