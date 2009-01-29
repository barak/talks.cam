class StatisticsController < ApplicationController
  
  def index
    # Users
    @number_of_users = User.count
    @number_of_recent_users = User.count :conditions => ['last_login > ?',1.month.ago]
    
    # Talks
    @number_of_talks = Talk.count
    @number_of_past_talks = Talk.count :conditions => ['start_time < ?',Time.now]
    @number_of_future_talks = Talk.count :conditions => ['start_time >= ?',Time.now]
    
    # Lists
    @number_of_lists = List.count
    @number_of_user_favourites = User.count
    @number_of_venues = Venue.count
    @number_of_series = Talk.count_by_sql "select count(distinct series_id) from talks"
    @number_of_listings = @number_of_lists - @number_of_user_favourites - @number_of_venues - @number_of_series
  end
  
end
