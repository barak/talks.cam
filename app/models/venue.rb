# This makes it easy to pick out venues 
class Venue < List; 

  def Venue.find_public(*args)
    Venue.with_scope :find => { :conditions => ["ex_directory = 0"] } do
      Venue.find(*args)
    end
  end  
  
end
