class ReminderController < ApplicationController
  
  before_filter :ensure_user_is_logged_in

  def index
    @user = User.current
    @subscriptions = @user.email_subscriptions
  end
  
  def create
    EmailSubscription.create :list_id => params[:list], :user => User.current 
    redirect_to reminder_url
  end
  
  def destroy
    find_subscription
    return false unless user_can_edit_subscription?
    @subscription.destroy
    redirect_to reminder_url
  end
  
  private
  
  def find_subscription
    @subscription = EmailSubscription.find(params[:id])
  end
  
  def user_can_edit_subscription?
    return true if @subscription.editable?
    render :text => "Permission denied", :status => 401
    false
  end
  
end
