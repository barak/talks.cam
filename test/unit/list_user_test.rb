require File.dirname(__FILE__) + '/../test_helper'

class ListUserTest < Test::Unit::TestCase
  fixtures :list_users, :users

  def test_user_email_setter
    list_user = ListUser.create! :user_email => users(:vic).email
    assert_equal users(:vic), list_user.user
    list_user = ListUser.create! :user_email => 'new-manager@talks.cam.ac.uk'
    assert user = User.find_by_email('new-manager@talks.cam.ac.uk')
    assert_equal user, list_user.user
  end
  
  def test_user_email
    assert_equal users(:seriesowner).email, list_users(:seriesowner).user_email
  end
  
end
