require File.dirname(__FILE__) + '/../test_helper'
require 'search_controller'

# Re-raise errors caught by the controller.
class SearchController; def rescue_action(e) raise e end; end

class SearchControllerTest < Test::Unit::TestCase
  fixtures :lists, :users
  
  def setup
    @controller = SearchController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_featured_lists
    featured_list = List.create(:name => 'Featured Lists')
    10.times do 
      ListList.create!(:list => featured_list, :child => List.create!(:name => 'child') )
    end
    get :index
    featured = assigns(:featured_lists)
    assert_equal 3, featured.size
  end
  
  def test_search_list
    post :results, :search => 'list'
    assert_response :success
    lists = assigns(:lists)
    assert_kind_of Array, lists
    assert_equal 4, lists.size
    lists.each do |list|
      assert_kind_of List, list
      assert_equal false, list.ex_directory?
      assert_equal false, list.is_a?(Venue)
    end
  end
  
  def test_search_users
    post :results, :search => 'vic'
    assert_response :success
    users = assigns(:users)
    assert_equal(1, users.size)
    assert_equal(users(:vic), users.first)
  end
  
  def test_search_nothing
    post :results
    assert_response :success
    lists = assigns(:lists)
    assert_kind_of Array, lists
    assert_equal 0, lists.size
  end
  
  def test_cavendish_physical_society
    post :results, :search => 'caVendash'
    assert_response :success
    
    found_lists = assigns(:lists)
    assert_kind_of Array, found_lists
    assert_equal 1, found_lists.size
    assert_equal lists(:cavendish), found_lists.first
  end
  
 
  def test_ferret_list_index
    lists = [["Cavendish Astrophysics Summary", "This list includes all talks from the Cavendish Astrophysics seminar series and mini-seminars, and meetings of the probability and information reading group. \r\nTalks and other events should be added to those sublists rather than here.\r\n"], ["Committee Room, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=Committee+Room%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["HEP Seminar Room, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=HEP+Seminar+Room%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["Inference Group", "The seminar series of the Inference Group, Cavendish Laboratory. Our interests include Machine learning, information theory, human-computer interfaces, and Bayesian inference.\r\n\r\n<a href='http://www.inference.phy.cam.ac.uk/is/'>External Home Page</a>"], ["Mott Colloquium", "A fortnightly series of talks of general interest to the researchers in the Cavendish Laboratory."], ["Room 911, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=Room+911%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["Ryle Seminar Room, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=Ryle+Seminar+Room%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["TCM, Mott and CPS listing", "This list includes talks from the TCM seminar series, the Mott seminar series, and the Cavendish Physical Society seminar series. Talks should be not be added to this list.  "], ["To Be Determined, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=To+Be+Determined%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["erter, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=erter%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"]].sort
# Workaround for search failing is to remove details from search
#    lists = [["Cavendish Astrophysics Summary", "This list includes all talks from the Cavendish Astrophysics seminar series and mini-seminars, and meetings of the probability and information reading group. \r\nTalks and other events should be added to those sublists rather than here.\r\n"], ["Committee Room, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=Committee+Room%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["HEP Seminar Room, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=HEP+Seminar+Room%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["Room 911, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=Room+911%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["Ryle Seminar Room, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=Ryle+Seminar+Room%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["To Be Determined, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=To+Be+Determined%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"], ["erter, New Cavendish Laboratory", "\n\n<a href='http://www.cam.ac.uk/map/v3/drawmap.cgi?mp=main;xx=692;yy=590;mt=c;tl=erter%2C+New+Cavendish+Laboratory'>Click here for a map for the venue</a>"]].sort

    lists.each do |name,details|
      List.create :name => name, :details => details
    end
    results = List.find(:all,:conditions => ["name LIKE :search OR details LIKE :search",{:search => "%cavendish%"}]).map { |l| [l.name,l.details]}.sort
    assert_equal lists.size, results.size
    
    l_names = lists.map {|l| l.first }.sort
    r_names = results.map {|l| l.first }.sort
    assert_equal l_names, r_names
    assert_equal lists, results
  end
  
  private
  
  def rebuild(model)
      model.rebuild_index
  end
  
end
