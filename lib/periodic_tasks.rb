class PeriodicTasks
  
  def self.daily
    Mailer.send_mailshots
    RelatedTalk.update_all_lists_and_talks
    RelatedList.update_all_lists_and_talks
    User.update_ex_directory_status
    CGI::Session::ActiveRecordStore::Session.delete_all( ['updated_at < ?', 1.week.ago ] ) # Purge our old session table
    true
  end

end