class TalkController < ApplicationController
    
    before_filter :ensure_user_is_logged_in, :except => %w( show index vcal )
    
    def login_message
      "You need to be logged in to create or edit a talk."
    end
    
    # Methods for viewing talks
    
    def index
      find_talk || return_404
      render :layout => 'with_related'
    end
    
    def vcal
      find_talk || return_404
    	headers["Content-Type"] = "text/calendar; charset=utf-8"
    	render :text => [@talk].to_ics
  	end
    
    # Creating a talk
    def new
      create_talk
      set_usual_details
      return false unless user_can_edit_talk?
      @list = @talk.series
      render :action => 'edit'
    end
    
    def create
      @talk = Talk.new(params[:talk])
      return false unless user_can_edit_talk?
      if @talk.save
        flash[:confirm] = "Talk &#145;#{@talk.name}&#146; has been created"
        redirect_to talk_url(:id => @talk.id)
      else
        flash[:error] = "Sorry, there were problems creating &#145;#{@talk.name}&#146;."
        render :action => 'edit'
      end
    end
    
    # Deleting a talk
    def delete
      find_talk || return_404
      return false unless ensure_user_is_logged_in
      return false unless user_can_edit_talk?
      
      if request.get?
        # Just fall through to the delete view, to get confirmation
      
      elsif request.post?
        series = @talk.series
        @talk.sort_of_delete
        @talk.save
        flash[:confirm] = "Talk &#145;#{@talk.name}&#146; has been deleted."
        redirect_to list_url(:id => series.id)
      end
    end
            
    # Editing a talk
    
    def edit
      return false unless ensure_user_is_logged_in
      find_talk || create_talk
      return false unless user_can_edit_talk? 
      set_usual_details
      @list = @talk.series
    end
    
    def update
      return false unless ensure_user_is_logged_in
      # The following is to catch "redirect after login" GET requests
      # which can't possibly work due to having not stored the original POST data
      if !request.post?
        respond_to do |format|
          flash[:warning] = "Sorry, your talk was not saved, please try again."
          format.html { redirect_to list_details_url(:action => 'choose') }
        end
	return true
      end
      @talk = Talk.new unless find_talk
      @talk.attributes = params[:talk]
      return false unless user_can_edit_talk?       
      respond_to do |format|
        if @talk.save
          flash[:confirm] = "Talk &#145;#{@talk.name}&#146; has been saved."
          format.html { redirect_to talk_url(:id => @talk.id) }
          format.xml  { head :ok, :location => talk_url(:id => @talk.id)}
        else
          format.html { render :action => 'edit' }
          format.xml  { render :xml => @talk.errors.to_xml }
        end
      end
    end
        
    # Helper methods for ajax requests
    
    def help
      @list = List.find params[:list_id]
      @usual_details = UsualDetails.new @list
      render :partial => "help_#{params[:field]}"
    end
    
    def venue_list
      return render(:nothing => true ) unless params[:search] && params[:search].size > 2
      search_term = params[:search].downcase.gsub(/[^a-z A-Z0-9]+/,'').gsub(' ','.*')
      @venues = Venue.find(:all, :conditions => [ 'LOWER(name) REGEXP ?',"[[:<:]]#{search_term}"], :order => 'name ASC', :limit => 20)
      render :partial => 'venue', :collection => @venues
    end
    
    def speaker_email_list
      return render(:nothing => true ) unless params[:search] && params[:search].size > 2
      search_term = params[:search].downcase.gsub(/[^a-z A-Z0-9]+/,'').gsub(' ','.*')
      @users = User.find(:all, :conditions => [ 'LOWER(email) REGEXP ?',"[[:<:]]#{search_term}"], :order => 'name ASC', :limit => 20)
      render :partial => 'user', :collection => @users
    end
    
    def speaker_name_list
      return render(:nothing => true ) unless params[:search] && params[:search].size > 2
      search_term = params[:search].downcase.gsub(/[^a-z A-Z0-9]+/,'').gsub(' ','.*')
      @users = User.find(:all, :conditions => [ 'LOWER(name) REGEXP ?',"[[:<:]]#{search_term}"], :order => 'name ASC', :limit => 20)
      render :partial => 'user', :collection => @users
    end
    
    # Filters
    
    private
    
    def set_usual_details
      @usual_details ||= UsualDetails.new @talk.series
    end
    
    def find_talk
      return nil unless params[:id]
      @talk = Talk.find params[:id]
    end
    
    def create_talk
      @usual_details = UsualDetails.new( List.find( params[:list_id] ) )
      @talk = @usual_details.default_talk
      @talk.ex_directory = true
    end
    
    def user_can_edit_talk?
      return true if @talk.editable?
      render :text => "Permission denied", :status => 401
      false
    end
    
    def return_404
      raise ActiveRecord::RecordNotFound.new
    end    
end
