class RefactorRelationships < ActiveRecord::Migration
  def self.up
    create_table "list_lists" do |t|
      t.column 'list_id', :integer
      t.column 'child_id', :integer
      t.column 'dependency', :string
    end
    create_table "list_talks" do |t|
      t.column 'list_id', :integer
      t.column 'talk_id', :integer
      t.column 'dependency', :string
    end
    
    # Add the old list relationships
    connection = ActiveRecord::Base.connection
    
    # Work our way through the old list_lists
    connection.select_all('select * from lists_lists where result_of_direct_parent_id').each do |link|
      p link
      parent = List.find(link['parent_id'].to_i)
      child = List.find(link['child_id'].to_i)
      parent.add(child)
    end
    
    # Work our way through the old list_talks
    connection.select_all('select * from lists_talks').each do |link|
      p link
      begin
        list = List.find(link['list_id'].to_i)
        talk = Talk.find(link['talk_id'].to_i)
        list.add(talk)
      rescue ActiveRecord::RecordNotFound => error
        puts "Not found "+error
      end
    end
    
    # Drop the old tables
     drop_table 'lists_lists'
     drop_table 'lists_talks'
  end

  def self.down
    drop_table "list_lists" 
    drop_table "list_talks"
    raise IrreversibleMigration
  end
end
