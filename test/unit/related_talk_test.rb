require File.dirname(__FILE__) + '/../test_helper'

class RelatedTalkTest < Test::Unit::TestCase
  fixtures :lists, :talks
  
  def test_update_on_create
    update_on_create_test(List, { :name => 'relatedtalktest' } )
    update_on_create_test(Talk, { } )
  end
  
  def update_on_create_test(type, options)
    owner = type.create( options )
    assert_equal false, owner.related_talks.empty?
  end
  
  def test_create_related_talks
    create_and_test_related_list_for lists(:one)
    create_and_test_related_list_for talks(:one)
  end
  
  def test_create_for_all_lists_and_talks
    List.find(:all).each { |list| assert_equal true, list.related_talks.empty?}
    Talk.find(:all).each { |talk| assert_equal true, talk.related_talks.empty?}
    RelatedTalk.update_all_lists_and_talks
    List.find(:all).each { |list| assert_equal false, list.related_talks.empty?}
    Talk.find(:all).each { |talk| assert_equal false, talk.related_talks.empty?}
  end
  
  def create_and_test_related_list_for(owner)
    assert_kind_of Array, owner.related_talks
    assert_equal true, owner.related_talks.empty?
    RelatedTalk.create_for( owner )
    assert_equal false, owner.related_talks.empty? # Should be 10, but not enough in our test data
    owner.related_talks.each do |related_talk|
      talk = related_talk.talk
      assert_kind_of Talk, talk
      assert_equal true, talk.start_time > Time.now
      assert_equal false, (talk == owner)
      assert_equal false, talk.ex_directory?
    end
    assert_equal owner.related_talks.uniq.size, owner.related_talks.size
  end
end
