class ListUserController < ApplicationController

  before_filter :find_models, :except => %w{ auto_complete_for_user_email }  
  before_filter :ensure_user_is_logged_in, :except => %w{ index auto_complete_for_user_email }
  before_filter :check_can_edit_model, :except => %w{ index auto_complete_for_user_email }
  
  auto_complete_for :user, :email
  
  def index
    @users = @list.users
  end

  def edit
    @list_users = @list.list_users
    @list_user = ListUser.new(:list => @list)
  end

  def create
    @list_user = ListUser.create!(params[:list_user])
    
    respond_to do |format|
      format.html { redirect_to_edit_page }
    end
  end

  def destroy
    @list_user.destroy

    respond_to do |format|
      format.html { redirect_to_edit_page }
    end
  end
  
  private
  
  def find_models
    if params[:id]
      @list_user = ListUser.find(params[:id])
      @list = @list_user.list
    else
      @list = List.find(params[:list_id] || params[:list_user][:list_id])
    end
  end
  
  def check_can_edit_model
    return true if @list.editable?
    render :text => "Permission denied", :status => 401
    false
  end
  
  def redirect_to_edit_page
    redirect_to list_user_url(:action => 'edit', :list_id => @list.id)
  end
end
