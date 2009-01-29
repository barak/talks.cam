require File.dirname(__FILE__) + '/../test_helper'

class RelatedListTest < Test::Unit::TestCase
  fixtures :lists, :talks
  
  def test_update_on_create
    update_on_create_test( List, { :name => 'relatedlisttest' } )
    update_on_create_test( Talk, { } )
  end
  
  def update_on_create_test(type, options)
    owner = type.create( options )
    assert_equal false, owner.related_lists.empty?
  end
  
  def test_create_related_lists
    create_and_test_related_list_for lists(:one)
    create_and_test_related_list_for talks(:one)
  end
  
  def test_create_for_all_lists_and_talks
    List.find(:all).each { |list| assert_equal true, list.related_lists.empty?}
    Talk.find(:all).each { |talk| assert_equal true, talk.related_lists.empty?}
    RelatedList.update_all_lists_and_talks
    List.find(:all).each { |list| assert_equal false, list.related_lists.empty?}
    Talk.find(:all).each { |talk| assert_equal false, talk.related_lists.empty?}
  end
  
  def create_and_test_related_list_for(owner)
    assert_kind_of Array, owner.related_lists
    assert_equal true, owner.related_lists.empty?
    RelatedList.create_for( owner )
    assert_equal 3, owner.related_lists.size
    owner.related_lists.each do |related_list|
      list = related_list.list
      assert_equal true, list.is_a?(List)
      assert_equal false, list.is_a?(Venue)
      assert_equal false, (list == owner)
      assert_equal false, list.ex_directory?
    end
    assert_equal owner.related_lists.uniq.size, owner.related_lists.size
  end
end
