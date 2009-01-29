require File.dirname(__FILE__) + '/../test_helper'

class ListTalkTest < Test::Unit::TestCase
  fixtures :list_talks, :talks, :lists, :list_lists

  def test_basics
    assert_equal false, lists(:one).talks.empty?
    assert lists(:two).talks.empty?
    assert lists(:three).talks.empty?
    
    assert_equal 1, lists(:one).talks(true).size
    assert_equal 1, lists(:one).talks.direct.size
    
    assert_equal talks(:one), lists(:one).talks(true).first
    assert_equal talks(:one), lists(:one).talks.direct.first
  end
  
  def test_add_talk
    lists(:two).add talks(:two)
    
    #puts
    #puts ListTalk.find(:all).join("\n")
    #puts
    
    assert_equal 1, lists(:one).talks(true).size
    assert_equal 1, lists(:one).talks.direct.size
    
    assert_equal 1, lists(:two).talks(true).size
    assert_equal 1, lists(:two).talks.direct.size
    
    assert_equal 1, lists(:three).talks(true).size
    assert_equal 0, lists(:three).talks.direct.size
  end
  
  def test_add_list
  
    lists(:two).add(lists(:one))  # 3 -> 2 -> 1
    lists(:four).add(lists(:three)) # 4 -> 3 -> 2 -> 1
    
    #puts
    #puts ListList.find(:all).join("\n")
    #puts
    #puts ListTalk.find(:all).join("\n")
    #puts
    
    assert_equal 1, lists(:one).talks(true).size
    assert_equal 1, lists(:one).talks.direct.size
    
    assert_equal 1, lists(:two).talks(true).size
    assert_equal 0, lists(:two).talks.direct.size
    
    assert_equal 1, lists(:three).talks(true).size
    assert_equal 0, lists(:three).talks.direct.size
    
  end
  
  def test_remove_talk
    test_add_list
    
    lists(:one).remove(talks(:one))
    
    assert_equal 0, lists(:one).talks(true).size
    assert_equal 0, lists(:one).talks.direct.size
    
    assert_equal 0, lists(:two).talks(true).size
    assert_equal 0, lists(:two).talks.direct.size
    
    assert_equal 0, lists(:three).talks(true).size
    assert_equal 0, lists(:three).talks.direct.size
    
    assert_equal 0, lists(:four).talks(true).size
    assert_equal 0, lists(:four).talks.direct.size
  end
  
  def test_remove_list
    test_add_list # Lists: 4 -> 3 -> 2 -> 1 # Talks: 1 -> talk 1 
    
    # puts
    # puts ListList.find(:all).join("\n")
    # puts
    # puts ListTalk.find(:all).join("\n")
    # puts
    
    lists(:three).remove(lists(:two))
    
    assert_equal 1, lists(:one).talks(true).size
    assert_equal 1, lists(:one).talks.direct.size
    
    assert_equal 1, lists(:two).talks(true).size
    assert_equal 0, lists(:two).talks.direct.size
    
    assert_equal 0, lists(:three).talks(true).size
    assert_equal 0, lists(:three).talks.direct.size
    
    assert_equal 0, lists(:four).talks(true).size
    assert_equal 0, lists(:four).talks.direct.size
  end
  
  def test_remove_talk_from_series
    assert_equal 1, lists(:series).talks.direct.size
    assert_raise CannotRemoveTalk do
      lists(:series).remove(talks(:with_series))
    end
    assert_equal 1, lists(:series).talks(true).direct.size

    assert_nothing_raised CannotRemoveTalk do
      lists(:series).remove(talks(:with_series),false)
    end
    assert_equal 0, lists(:series).talks(true).direct.size
  end
  
  def test_remove_talk_from_venue
    assert_equal 1, lists(:venue).talks.direct.size
    assert_raise CannotRemoveTalk do
      lists(:venue).remove(talks(:with_venue))
    end
    assert_equal 1, lists(:venue).talks(true).direct.size
    assert_nothing_raised CannotRemoveTalk do
      lists(:venue).remove(talks(:with_venue),false)
    end
    assert_equal 0, lists(:venue).talks(true).direct.size
  end
  
end
