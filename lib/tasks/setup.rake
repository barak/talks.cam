def each_database
  ['production','testing','development'].each do |type|
    yield "talks2_#{type}"
  end
end

namespace 'talks' do
  
  desc 'Setup the mysql databases'
  task :setup_mysql_databases do
    each_database do |database|
      `mysqladmin -u root create #{database}`
    end
  end
  
  desc 'Setup the mysql users'
  task :setup_mysql_users do
    require 'open3'
    Open3.popen3('mysql -u root') do |stdin, stdout, stderr|
      Thread.new { loop { puts "Err: #{stderr.gets}" } }
      Thread.new { loop { puts "Out: #{stdout.gets}" } }
      stdin.puts "grant usage on *.* to talks2@localhost identified by 'dreamsoffunkythings';"
      each_database do |database|
        stdin.puts "grant all on #{database}.* to talks2@localhost;"
      end
    end
  end 
  
  desc 'Setup database and users'  
  task :setup_mysql_databases_and_users => [:setup_mysql_databases,:setup_mysql_users] do
    # Nothing extra
  end
  
  desc 'Install the required gems'
  task :install_gems do 
    ['rails','ferret --version 0.3.2','redcloth --version 3.0.3','icalendar','fcgi','stemmer'].each do |gem|
      `sudo gem install --include-dependencies #{gem}`
    end
  end
  
  desc 'Give admin privelages to a select few'
  task :give_admin_privelages do
    require File.dirname(__FILE__) + '/../../config/environment'
    ['tamc2@cam.ac.uk','mackay@mrao.cam.ac.uk'].each do |email|
      User.find_by_email(email).update_attribute('administrator',true)
    end
  end

end
