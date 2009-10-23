class IndexController < ApplicationController
  
 # These are alphabetical
  def talks
    @talks = index_for Talk
  end
  
  def lists
    @lists = index_for List
  end
  
  def venues
    @lists = index_for Venue
  end

  def users
    @users = index_for User
  end
  
  def dates
    begin
      @time = (time_from_parameters || Time.now).at_beginning_of_day
    rescue ArgumentError => e
      render_404
      return
    end
    @year, @month, @day = @time.year, @time.month, @time.day
    @talks = Talk.find_public :all, :conditions => ['start_time BETWEEN ? AND ?',@time,@time+1.day], :order => 'start_time ASC'
  end
  
  private
  
  def index_for( klass )
      case params[:letter]
      when 'new'
        return klass.find_public(:all, :order => 'created_at DESC',:limit => 30)
      when 'updated'            
        return klass.find_public(:all, :order => 'updated_at DESC',:limit => 30)
      else                      
        return klass.find_public(:all, 
                  :conditions => ["#{klass.sort_field} LIKE ?","#{params[:letter]}%"], 
                  :order => "#{klass.sort_field} ASC")
      end
  end
  
  def time_from_parameters
    return nil unless params[:year] && params[:month] && params[:day]
    Time.local params[:year], params[:month], params[:day]
  end
end
