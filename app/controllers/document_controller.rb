class DocumentController < ApplicationController
  
  before_filter :find_document_for_name, :except => [:index, :recent_changes]
  before_filter :ensure_user_is_logged_in, :only => [:edit,:save]
  before_filter :check_can_edit, :only => [:edit,:save]
  
  def index
    @documents = Document.find :all, :order => 'name ASC'
  end
  
  def recent_changes
    @versions = Document::Version.find( :all, :order => 'updated_at DESC', :limit => 100)
  end
  
  def find_document_for_name
    @document = Document.find_by_name @params[:name].underscore
  end
  
  def show
    redirect_to :action => 'edit', :name => @params[:name] unless @document
  end

  # Can be overridden in individual controllers
  def login_message
    "You need to be logged in to edit one of these documents."
  end

  def check_can_edit
    return true unless @document
    return true if @document.can_edit?
    flash[:error] = "Only an admininstrator may edit this document."
    redirect_to :action => 'show', :name => @document.name
    return false
  end  
  
  def edit
    @document ||= Document.new(:name => @params[:name])
  end

  def save
    @document ||= Document.new(:name => @params[:name])
    @document.body = @params[:document][:body]
    if User.current.administrator?
      @document.administrator_only = @params[:document][:administrator_only]
    end
    @document.save
    flash[:confirm] = "Your changes have been saved."
    redirect_to :action => 'show', :name => @document.name
  end
  
end
