require File.dirname(__FILE__) + '/../test_helper'

class ListTest < Test::Unit::TestCase
  fixtures :lists, :users, :list_users
  
  def test_public_finder
    public_lists = List.find_public(:all)
    assert_equal false, public_lists.any? {|list| list.ex_directory? }
    assert_equal false, public_lists.any? {|list| list.is_a? Venue }
    assert_equal false, public_lists.any? {|list| list.name == "Name to be confirmed" }
  end
  
  def test_random_list
    assert_equal 3, List.random(3).size
    assert_equal false, List.random(List.find(:all).size,lists(:one).id).include?(lists(:one))
  end
  
  def test_sort_field
    assert_equal 'name', List.sort_field
  end
  
  def test_usual_details
    usual_details = UsualDetails.new( List.find( 8 ))
    assert_equal UsualDetails::DEFAULT_TIMINGS, usual_details.timings
    assert_equal UsualDetails::DEFAULT_TIMINGS.first, usual_details.default_talk.time_slot
  end

  def test_manager_alias
    assert_equal lists(:series).users.first, lists(:series).managers.first
  end
  
  def test_find_or_create_by_name_while_checking_management
    # An existing list
    User.current = users(:seriesowner)
    list = List.find_or_create_by_name_while_checking_management(lists(:series).name)
    assert_equal lists(:series), list
    
    # A new list, but with the same name as an existing one
    User.current = users(:jim)
    list = List.find_or_create_by_name_while_checking_management(lists(:series).name)
    assert_not_equal lists(:series), list
    assert_equal lists(:series).name, list.name
    assert_equal [users(:jim)], list.managers

    # The same list as before (ie there are now two lists with the same name, needs to pick the one that this user manages)
    assert_equal 2, List.find_all_by_name(lists(:series).name).size

    User.current = users(:jim)
    picked_list = List.find_or_create_by_name_while_checking_management(lists(:series).name)
    assert_equal list, picked_list

    User.current = users(:seriesowner)
    picked_list = List.find_or_create_by_name_while_checking_management(lists(:series).name)
    assert_equal lists(:series), picked_list
    
    # A brand new list
    User.current = users(:jim)
    list2 = List.find_or_create_by_name_while_checking_management('A completely new name')
    assert_equal 'A completely new name', list2.name
    assert_equal [users(:jim)], list2.managers
    
  end

  def test_ex_directory
    parent_list = List.create :name => 'Parent list'
    list = List.create :name => 'list one'
    parent_list.add list
    
    talk_in_series = Talk.create :title => 'talk in series', :series => list
    talk_not_in_series = Talk.create :title => 'talk not in series'
    list.add talk_not_in_series
    
    assert_equal 1, list.parents.direct.size
    assert_equal 2, list.talks.size
    assert_equal 2, list.talks.direct.size
    assert_equal false, parent_list.ex_directory?
    assert_equal false, list.ex_directory?
    assert_equal false, talk_in_series.ex_directory?
    assert_equal false, talk_not_in_series.ex_directory?
    
    list.ex_directory = true;
    list.save
    
    # Reload
    [ list, parent_list, talk_not_in_series, talk_in_series ].each { |ar| ar.reload }

    assert_equal 1, list.parents.direct.size
    assert_equal 2, list.talks.size
    assert_equal 2, list.talks.direct.size
    assert_equal false, parent_list.ex_directory?
    assert_equal true, list.ex_directory?
    assert_equal true, talk_in_series.ex_directory?
    assert_equal false, talk_not_in_series.ex_directory?
    
    return parent_list, list, talk_not_in_series, talk_in_series
  end
  
  def test_open_a_previously_ex_directory
    parent_list, list, talk_not_in_series, talk_in_series = test_ex_directory
    
    list.ex_directory = false;
    list.save
    
    # Reload
    [ list, parent_list, talk_not_in_series, talk_in_series ].each { |ar| ar.reload }
        
    assert_equal 1, list.parents.direct.size
    assert_equal 2, list.talks.size
    assert_equal 2, list.talks.direct.size
    assert_equal false, parent_list.ex_directory?
    assert_equal false, list.ex_directory?
    assert_equal false, talk_in_series.ex_directory?
    assert_equal false, talk_not_in_series.ex_directory?     
  end
  
  def test_sort_of_delete
    parent_list = List.create :name => 'Parent list'
    user = User.create :name => 'test user', :email => 'test@test.test'
    
    list = List.create :name => 'list one'
    list.users << user
    list.save
    parent_list.add list
    
    talk_in_series = Talk.create :title => 'talk in series', :series => list
    talk_not_in_series = Talk.create :title => 'talk not in series'
    list.add talk_not_in_series
    
    assert_equal 1, parent_list.children.direct.size
    assert_equal 2, list.talks.size
    assert_equal 2, list.talks.direct.size
    assert_equal 1, list.users.size
    assert_equal 2, user.lists(true).size
    assert_equal false, parent_list.ex_directory?
    assert_equal false, list.ex_directory?
    assert_equal false, talk_in_series.ex_directory?
    assert_equal false, talk_not_in_series.ex_directory?
    
    list.sort_of_delete;
    list.save
    
    # Reload
    [ list, parent_list, talk_not_in_series, talk_in_series, user ].each { |ar| ar.reload }
    
    assert_equal 0, parent_list.children.direct.size
    assert_equal 1, user.lists(true).size
    assert_equal 1, list.talks.size
    assert_equal 1, list.talks.direct.size
    assert_equal 0, list.users.size
    assert_equal false, parent_list.ex_directory?
    assert_equal true, list.ex_directory?
    assert_equal true, talk_in_series.ex_directory?
    assert_equal false, talk_not_in_series.ex_directory?
    
  end
  
  def test_tilde_in_url_in_details
    list = List.create :name => 'test list', :details => 'http://test.cam.ac.uk/~tamc2/eng'
    assert_equal '<p><a href="http://test.cam.ac.uk/~tamc2/eng">http://test.cam.ac.uk/~tamc2/eng</a></p>', list.details_filtered
  end
  
  def test_xss_prevention
    list = List.new
    fields = %w{name}
    fields.each {|field| list.send("#{field}=","Test <tags> are </tags> <escaped/>") }
    list.save
    fields.each do |field|
      assert_equal "Test &lt;tags&gt; are &lt;/tags&gt; &lt;escaped/&gt;", list.send(field),"Field: #{field}"
    end
    
    list.details = "A <hr/> <a href=\"javascript:alert('gotcha')\" onclick=\"attack()\">Hello</a>"
    list.save
    assert_equal "A <hr/> <a href=\"javascript:alert('gotcha')\" onclick=\"attack()\">Hello</a>", list.details
    assert_equal "<p>A   <a href=\"\">Hello</a></p>", list.details_filtered
    
  end
  
  def test_ability_to_add_an_image
    list = List.create!(:name => 'a list with a pretty picture')
    # As an image object
    list.image = an_image
    assert_kind_of Image, list.image
    # As data
    image_file do |file|
      list.image = file
    end
    assert_kind_of Image, list.image
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
  
end