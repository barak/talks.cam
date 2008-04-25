require File.dirname(__FILE__) + '/../test_helper'

class CustomViewTest < Test::Unit::TestCase
  fixtures :custom_views

  # Replace this with your real tests.
  def test_truth
    assert_kind_of CustomView, custom_views(:first)
  end
end
