class PeriodicTasks
  
  def self.daily
    RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: Start")

    begin
      RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: About to send out emails")
      Mailer.send_mailshots
      RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: Finished sending emails")
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.error("PeriodicTasks.daily @ #{Time.now}: ERROR:\n#{e.message}\n" + e.backtrace.join("\n"))
      $stderr.puts "=== ERROR: Nightly Emailer Failed:\n"
      $stderr.puts e.message, e.backtrace
    end

    begin
      RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: About to update users ex-directory status")
      User.update_ex_directory_status
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.error("PeriodicTasks.daily @ #{Time.now}: ERROR:\n#{e.message}\n" + e.backtrace.join("\n"))
      $stderr.puts "=== ERROR: Failed updating users ex-directory status:\n"
      $stderr.puts e.message, e.backtrace
    end

    RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: About to purge old sessions")
    CGI::Session::ActiveRecordStore::Session.delete_all( ['updated_at < ?', 1.week.ago ] ) # Purge our old session table

    RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: About to call RelatedList.update_all_lists_and_talks")
    RelatedList.update_all_lists_and_talks

    RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: About to call RelatedTalk.update_all_lists_and_talks")
    RelatedTalk.update_all_lists_and_talks

    RAILS_DEFAULT_LOGGER.info("PeriodicTasks.daily @ #{Time.now}: Finished")

    true
  end

end
