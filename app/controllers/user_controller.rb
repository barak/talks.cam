class UserController < ApplicationController
  before_filter :ensure_user_is_logged_in, :except => %w( new show create password_sent )
  before_filter :find_user, :except => %w( new create password_sent )
  before_filter :check_can_edit_user, :except => %w( new show create password_sent show index )
  
  # Filters
  
  def find_user
    @user = User.find params[:id]
  end
  
  def check_can_edit_user
    return true if @user.editable?
    flash[:error] = "You do not have permission to edit &#145;#{@user.name}}&#146;"
    render :text => "Permission denied", :status => 401
    false
  end
  
  # Actions
  
  def show
    @show_message = session['return_to'] ? true : false
  end
  
  def edit
    @show_message = session['return_to'] ? true : false
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:confirm] = 'A new account has been created.'
      redirect_to :action => 'password_sent'
    else
      render :action => 'new'
    end
  end
  
  def update    
    if @user.update_attributes(params[:user])
      flash[:confirm] = 'Saved.'
      redirect_to user_url(:id => @user.id)
    else
      if params[:user][:password] # Then we must be trying to change the password and have failed
        render :action => 'change_password'
      else
        render :action => 'edit'
      end
    end
  end
end
