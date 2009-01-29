class AddOrganiser < ActiveRecord::Migration
  def self.up
    add_column "talks", "organiser_id", :integer
    say "Adding the first series manager as the default organiser for a talk"
    Talk.find(:all).each do |talk|
      talk.organiser = talk.series.users.first
      talk.save
    end
  end

  def self.down
    remove_column "talks", "organiser_id"
  end
end
