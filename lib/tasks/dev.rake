def sql_file( name = 'production' )
  File.dirname(__FILE__) + "/../../tmp/#{name}.sql"
end

namespace 'dev' do
  
  namespace 'production' do
    desc 'Downloads a copy of the production database from the remote server.  Set PASSWORD=remote db password'
    task :remote_download do
      $stderr.puts "Download from live talks site to #{sql_file}"
      puts `ssh talks mysqldump --single-transaction --quick  --add-drop-table --user talks --password='#{ENV['PASSWORD']}' talks > #{sql_file}`
    end
    
    desc 'Dumps a copy of the local production database.  Set PASSWORD=local database password'
    task :dump do
      $stderr.puts "Dumping local talks_production to #{sql_file}"
      puts `mysqldump  --single-transaction --quick --add-drop-table --user talks2 --password='#{ENV['PASSWORD']}' talks2_production > #{sql_file}`
    end
  end
  
  desc "Replaces the development data with production data from #{sql_file}.  Set PASSWORD=local database password"
  task :replace_development_data do
    puts `mysql --user talks2 --password='#{ENV['PASSWORD']}' talks2_development < #{sql_file}`
  end
  
  desc "Purges email subscriptions, a good idea for the development database"
  task :purge_email_subscriptions do
    require File.dirname(__FILE__) + '/../../config/environment'
    EmailSubscription.delete_all
  end
    
  def remove_asset_tag( filename )
    file = IO.readlines(filename)
    file.each do |line|
      line.gsub!(/config\.action_controller\.asset_host/,'# config.action_controller.asset_host')
      line.gsub!(/^ENV\[\'RAILS_ENV\'\] \|\|\= \'production\'/,"# ENV['RAILS_ENV'] ||= 'production'")
    end
    File.open(filename,'w') do |f|
      f.puts file.join
    end 
  end
  
  desc 'Removes the asset tag lines in the environment.rb and development.rb files that point at the main talks.cam site'
  task :remove_asset_tags do
    remove_asset_tag File.dirname(__FILE__) + "/../../config/environment.rb"
    remove_asset_tag File.dirname(__FILE__) + "/../../config/environments/development.rb"
  end
  
  desc 'Set permissions on fast and cgi scripts'
  task :set_permissions do
    # Execute privelages
    ['public','public/dispatch.cgi','public/dispatch.fcgi','public/dispatch.rb','script/*','script/process/*'].each do |file|
      p `chmod a+x #{File.dirname(__FILE__) + '/../../' + file }`
    end
    # Write privelages
    ['tmp','log','public/list','public/talk','public/user'].each do |file|
      p `chmod -R a+rw #{File.dirname(__FILE__) + '/../../' + file }`
    end
  end
  
  desc 'Does some preparation. Only appropriate for tamc2'
  task :prep => [:remove_asset_tags, :set_permissions] do
    `cp #{File.dirname(__FILE__)}/../../../live/config/database.yml #{File.dirname(__FILE__)}/../../config/`
  end
end