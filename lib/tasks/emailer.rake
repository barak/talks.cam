namespace 'talks' do
  
  desc 'Manually send emails to those that have subscribed through talks.cam'
  task :send_emails do
    require File.dirname(__FILE__) + '/../../config/environment'
    s = Emailer.new
    s.send_messages
  end
end