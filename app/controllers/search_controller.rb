class SearchController < ApplicationController
  
  layout 'front'
  
  def index
    @featured_talks = List.find_or_create_by_name 'Featured talks'
    
    @featured_list = List.find_or_create_by_name 'Featured lists'
    @featured_lists = three_random_items_from( @featured_list.children.direct )
    
    document = Document.find_or_create_by_name 'Message of the Day'
    @motd = document.html unless !document.body || document.body.empty?
  end
  
  def results
    @time_at_beginning_of_day = Time.new.beginning_of_day
    @search = params[:search]
    unless @search && !@search.empty?
      @talks, @lists, @users = [], [], []
    else
      @talks = Talk.find :all, :conditions => ["title LIKE :search OR abstract LIKE :search OR name_of_speaker LIKE :search",{:search => "%#{@search.strip}%"}]
      @lists = List.find :all, :conditions => ["name LIKE :search OR details LIKE :search",{:search => "%#{@search.strip}%"}]
      @users = User.search(@search)
    end
    @lists.delete_if { |list| list.ex_directory? }
    @talks.delete_if { |talk| talk.ex_directory? }
    @venues, @lists = @lists.partition { |list| list.is_a? Venue }
    @future_talks, @past_talks = @talks.partition { |talk| talk.start_time && (talk.start_time >= @time_at_beginning_of_day) }
  end
  
  private
  
  def three_random_items_from( array )
    return array if array.size <= 3
    random_indices = [1,1,1]
    random_indices = [ rand(array.size), rand(array.size), rand(array.size)] until random_indices.uniq! == nil # ie uniq doesn't eliminate anything a unique set
    [ array[random_indices[0]], array[random_indices[1]], array[random_indices[2]] ]
  end
  
end
