require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users, :lists
  
  def test_find_public
    public_users = User.find_public(:all)
    assert_equal false, public_users.any? {|user| user.ex_directory?}
  end
  
  def test_password_generated_upon_create
    user = User.create :name => 'bob', :email => 'not an email'
    assert_not_nil user.password
  end
  
  def test_search
    assert_equal([users(:jim),users(:vic)], User.search('test'))
  end
  
  def test_sort_field
    assert_equal 'name_in_sort_order', User.sort_field
  end
  
  def test_new_list_on_create
    user = User.create :name => 'bob', :email => 'not an email'
    assert_equal 1, user.lists(true).size
    assert_not_nil user.personal_list
    assert_equal "bob's list", user.personal_list.name
    user = User.create :email => 'still not an email'
    assert_equal 1, user.lists(true).size
    assert_not_nil user.personal_list
    assert_equal "Your personal list", user.personal_list.name
    user = User.create :email => 'still not an email2', :crsid => 'tamc2'
    assert_equal 1, user.lists(true).size
    assert_not_nil user.personal_list
    assert_equal "tamc2's list", user.personal_list.name
  end
  
  def test_send_email_upon_create
    user = User.create! :name => 'bob', :email => 'webmaster@talks.cam.ac.uk', :send_email => true
    assert Mailer.deliveries.find { |mail| mail.to && (mail.to[0] == user.email) }
    user = User.create! :name => 'bill', :email => 'webmaster2@talks.cam.ac.uk'
    assert !Mailer.deliveries.find { |mail| mail.to && (mail.to[0] == user.email) }
  end
  
  def test_subscribe
    user = User.create :name => 'bob', :email => 'not an email'
    user.subscribe_to_list lists(:one)
    assert_equal 1, user.email_subscriptions.size
    assert_equal lists(:one), user.email_subscriptions.first.list
  end
  
  def test_send_email
    user = User.create :name => 'bob', :email => 'sending@email'
    user.send_emails_about_personal_list = '1'
    assert_equal 1, user.email_subscriptions.size
    assert_equal user.personal_list, user.email_subscriptions.first.list
    user.send_emails_about_personal_list = '0'
    user.reload
    assert_equal 0, user.email_subscriptions.size
  end
  
  def test_find_or_create_by_crsid
    user = User.find_or_create_by_crsid 'testid'
    assert_equal 'testid', user.crsid
    assert_equal 'john@talks.cam', user.email
    assert_equal 'john jones', user.name
    
    user = User.find_or_create_by_crsid 'crsid'
    assert_equal 'crsid', user.crsid
    assert_equal 'with existing crsid', user.name
    assert_equal 'somewhere', user.affiliation
    
    user = User.find_or_create_by_crsid 'tamc2'
    assert_equal 'tamc2', user.crsid
    assert_equal 'tamc2@cam.ac.uk', user.email
    assert_equal 'University of Cambridge', user.affiliation
  end
  
  def test_set_crsid_from_email
    user = User.create :email => 'tamc2@cam.ac.uk'
    assert_equal 'tamc2', user.crsid
    user.email = 'webmaster@talks.cam.ac.uk'
    user.save!
    assert_equal 'tamc2', user.crsid
    user.email = 'cmw26@cam.ac.uk'
    user.save!
    assert_equal 'cmw26', user.crsid
  end
  
  def test_set_name_in_sort_order_from_name
    user = User.create! :email => 'sorted-user@talks.cam.ac.uk'
    assert_equal "", user.name_in_sort_order
    user.name = 'tamc2'
    user.save!
    assert_equal 'tamc2', user.name_in_sort_order
    user.name = 'Tom Counsell'
    user.save!
    assert_equal 'Counsell, Tom', user.name_in_sort_order
    user.name = 'Thomas Allan Malet Counsell'
    user.save!
    assert_equal 'Counsell, Thomas Allan Malet', user.name_in_sort_order
    user.name = 'Thomas Allan Malet Counsell'
    user.save!
    assert_equal 'Counsell, Thomas Allan Malet', user.name_in_sort_order    
  end
  
  def test_update_ex_directory_status
    user = User.create! :email => 'ex-directory-user@talks.cam.ac.uk'
    assert user.ex_directory?
    user.update_ex_directory_status
    assert user.ex_directory?
    l = List.create! :name => 'test update ex dir status list'
    l.users << user
    user.reload
    user.update_ex_directory_status
    assert !user.ex_directory?
    t = Talk.create! :speaker_email => 'a-new-speaker@talks.cam.ac.uk'
    t.speaker.update_ex_directory_status
    assert !t.speaker.ex_directory?
    t = Talk.create! :organiser_email => 'organiser@talks.cam.ac.uk'
    t.organiser.update_ex_directory_status
    assert !t.organiser.ex_directory?
  end
  
  def test_xss_prevention
    user = User.new
    fields = %w{name email affiliation}
    fields.each {|field| user.send("#{field}=","Test@one.com <tags> are </tags> <escaped/>") }
    user.save
    fields.each do |field|
      assert_equal "Test@one.com &lt;tags&gt; are &lt;/tags&gt; &lt;escaped/&gt;", user.send(field),"Field: #{field}"
    end
  end
  
  def test_ability_to_update_password
    # Can't just do it
    user = User.create!(:email=>'passwordchanger')
    user.password = 'a new password'
    assert_equal false, user.save
    assert user.errors.on(:existing_password)
    
    # Must have a matching confirmation
    user.existing_password = user.password
    user.password = 'a new password'
    user.password_confirmation = 'a different password'
    assert_equal false, user.save
    assert user.errors.on(:password_confirmation)

    # Must have the existing password as well
    user.existing_password = user.password
    user.password = 'a new password'
    user.password_confirmation = 'a new password'
    assert_equal true, user.save
  end
  
  def test_ability_to_add_an_image
    user = User.create!(:email => 'someone pretty')
    # As an image object
    user.image = an_image
    assert_kind_of Image, user.image
    # As data
    image_file do |file|
      user.image = file
    end
    assert_kind_of Image, user.image
  end
  
  def test_error_with_invalid_image
    user = User.create!(:email => 'someone with an invalid picture')
    image = Image.create
    assert_equal(false, image.valid?)
    user.image = image
    assert_equal(false,user.valid?)
    assert user.errors.on(:image)
  end
  
  def an_image
    image_file do |file|
      image = Image.create :data => file
    end
  end
  
  def image_file
    File.open(gif_image,'r') do |f|
      f.extend FileCGICompatability
      yield f
    end
  end
  
  def test_needs_an_edit
    user = User.create!
    assert_equal true, user.needs_an_edit?
    user.last_login = Time.now
    assert_equal false, user.needs_an_edit?
  end
  
  def test_talks_organised
    user = User.create!
    talk1 = Talk.create! :organiser => user
    talk2 = Talk.create! :organiser => user
    talk3 = Talk.create! :organiser => user, :ex_directory => true
    assert_equal(2, user.talks_organised.size)
  end
  
end
