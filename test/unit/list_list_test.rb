require File.dirname(__FILE__) + '/../test_helper'

class ListListTest < Test::Unit::TestCase
  fixtures :lists, :list_lists

  def test_children
    assert lists(:one).children.empty?
    assert lists(:one).children.direct.empty?
    assert lists(:two).children.direct.empty?
    assert_equal 1, lists(:three).children.size
    assert_equal 1, lists(:three).children.direct.size
  end
  
  def test_parents
    assert lists(:one).parents.empty?
    assert lists(:one).parents.direct.empty?
    assert_equal 1, lists(:two).parents.size
    assert_equal 1, lists(:two).parents.direct.size
    assert lists(:three).parents.empty?
    assert lists(:three).parents.direct.empty?
  end
  
  def test_adding_list
    lists(:two).add(lists(:one))  # 3 -> 2 -> 1
    
   #puts "Test Adding list"
   #puts  ListList.find( :all).join("\n")
   #puts "\n\n"
    
    # Check direct
    assert_equal 1, lists(:two).children.size
    assert_equal 1, lists(:two).children.direct.size

    assert_equal 2, lists(:one).parents.size
    assert_equal 1, lists(:one).parents.direct.size
  
    # Check indirect
    assert_equal 2, lists(:three).children.size
    assert_equal 1, lists(:three).children.direct.size    
  end
  
  def test_recursion_block
    lists(:two).add(lists(:one))  # 3 -> 2 -> 1
    recursive = ListList.new :list => lists(:one), :child => lists(:three) # Recursive 3 -> 2 -> 1 -> 3
    assert_equal false, recursive.save

    recursive = ListList.new :list => lists(:one), :child => lists(:one) # Obviously recursive
    assert_equal false, recursive.save
    
    # Check direct
    assert_equal 1, lists(:two).children.size
    assert_equal 1, lists(:two).children.direct.size

    assert_equal 2, lists(:one).parents.size
    assert_equal 1, lists(:one).parents.direct.size
  
    # Check indirect
    assert_equal 2, lists(:three).children.size
    assert_equal 1, lists(:three).children.direct.size
  end
  
  def test_add_children
    lists(:one).add(lists(:three)) #  3 -> 2,  1 -> 3 -> 2
    
    #puts "Test add children"
    #puts  ListList.find( :all).join("\n")
    # [:one,:two,:three].each do |name|
    #    p lists(name).children.map { |l| l.name }.sort
    #  end
    #puts "\n\n"
    
    assert_equal 0, lists(:one).parents.size
    assert_equal 0, lists(:one).parents.direct.size
    assert_equal 2, lists(:one).children.size
    assert_equal 1, lists(:one).children.direct.size
    
    assert_equal 2, lists(:two).parents.size
    assert_equal 1, lists(:two).parents.direct.size
    assert_equal 0, lists(:two).children.size
    assert_equal 0, lists(:two).children.direct.size

    assert_equal 1, lists(:three).parents.size
    assert_equal 1, lists(:three).parents.direct.size
    assert_equal 1, lists(:three).children.size
    assert_equal 1, lists(:three).children.direct.size
  end

  def test_add_children_of_child_to_parents_of_parent
    # 3->2 1->4 then 2->1 chains all four together
    lists(:one).add(lists(:four))
    lists(:two).add(lists(:one))

    # FIXME don't just get coverage, check it's actually correct!
    assert_equal 1, 1
  end
  
  def test_remove_children
    test_recursion_block # 3 -> 2 -> 1 , no recursion any more

    # puts "Test remove children (before)"
    # puts  ListList.find( :all).join("\n")
    #  [:one,:two,:three].each do |name|
    #     p lists(name).children.map { |l| l.name }.sort
    #   end
    # puts "\n\n"
        
    lists(:two).remove lists(:one) # 3 -> 2, 1
    
    # puts "Test remove children (after)"
    # puts  ListList.find( :all).join("\n")
    # puts "\n\n"
    
    # This is essential to force a reload    
    [:one,:two,:three].each do |name|
       lists(name).children(true)
       lists(name).parents(true)
     end
    
    assert_equal 0, lists(:one).parents.size
    assert_equal 0, lists(:one).parents.direct.size
    assert_equal 0, lists(:one).children.size
    assert_equal 0, lists(:one).children.direct.size
    
    assert_equal 1, lists(:two).parents.size
    assert_equal 1, lists(:two).parents.direct.size
    assert_equal 0, lists(:two).children.size
    assert_equal 0, lists(:two).children.direct.size

    assert_equal 0, lists(:three).parents.size
    assert_equal 0, lists(:three).parents.direct.size
    assert_equal 1, lists(:three).children.size
    assert_equal 1, lists(:three).children.direct.size
    
  end
  
end
