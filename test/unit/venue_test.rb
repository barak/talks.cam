require File.dirname(__FILE__) + '/../test_helper'

class VenueTest < Test::Unit::TestCase
  fixtures :lists
  
  def test_find_public
    public_venues = Venue.find_public(:all)
    assert_equal true, public_venues.all? {|venue| venue.is_a? Venue }
    assert_equal false, public_venues.any? {|venue| venue.ex_directory? }
  end
  
end