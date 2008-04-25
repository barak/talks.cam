require File.dirname(__FILE__) + '/../test_helper'

class TalkFinderTest < Test::Unit::TestCase
  
  def test_default
    tf = TalkFinder.new
    assert_condition_set tf, 'start_time > ?', Time.now.at_beginning_of_day
    assert_order_set tf, "start_time ASC"
  end
  
  def test_full_monty
    parameters = { :limit => 10.to_s,
      :offset => 3.to_s,
      :limit => 1.to_s,
      :seconds_before_today => 1.day.to_s,
      :seconds_after_today => 1.day.to_s,
      :start_seconds => Time.local(2007,05,01).to_i.to_s,
      :end_seconds => Time.local(2008,05,02).to_i.to_s,
      :term => Time.local(2007,02).to_i.to_s,
      :reverse_order => '1'
    }
    tf = TalkFinder.new(parameters)
    assert_offset_set tf, '3'
    assert_limit_set tf, '1'
    # The relative dates
    assert_condition_set tf, 'start_time > ?', (Time.now.at_beginning_of_day - 1.day)
    assert_condition_set tf, 'start_time < ?', (Time.now.at_beginning_of_day + 1.day)
    # The absolute dates
    assert_condition_set tf, 'start_time > ?', Time.local(2007,05,01)
    assert_condition_set tf, 'start_time < ?', Time.local(2008,05,02)
    # Term date around 2007,02
    assert_condition_set tf, 'start_time > ?', Time.local(2007,1).at_beginning_of_month
    assert_condition_set tf, 'start_time < ?', Time.local(2007,3).at_end_of_month
    assert_order_set tf, "start_time DESC"
  end

  def test_alternative_times
    parameters = {
      :start_time => Time.local(2007,05,01).to_i.to_s,
      :end_time =>  Time.local(2008,05,02).to_i.to_s,
    }
    tf = TalkFinder.new(parameters)
    # The absolute dates
    assert_condition_set tf, 'start_time > ?', Time.local(2007,05,01)
    assert_condition_set tf, 'start_time < ?', Time.local(2008,05,02)
  end
  
  def test_current_term
    tf = TalkFinder.new :term => 'current'
    # Term date around 2007,02
    year = Time.now.year
    ignore, term_start, term_end = [ 
      [Time.local(year,1),1,3],
      [Time.local(year,4),4,6],
      [Time.local(year,7),7,9],
      [Time.local(year,10),10,12]
    ].reverse.find { |time,term_start,term_end| Time.now > time }
    assert_condition_set tf, 'start_time > ?', Time.local(year,term_start).at_beginning_of_month
    assert_condition_set tf, 'start_time < ?', Time.local(year,term_end).at_end_of_month    
  end
  
  private
  
  def assert_condition_set(tf, condition, setting = nil)
    conditions = tf.to_find_parameters[:conditions]
    assert_match condition, conditions.first
    assert_equal(true, conditions.include?(setting),"No setting found for #{condition} #{setting}") if setting
  end
  
  def assert_order_set(tf, order)
    assert_equal order, tf.to_find_parameters[:order]  
  end
  
  def assert_limit_set(tf, limit)
    assert_equal limit, tf.to_find_parameters[:limit]
  end
  
  def assert_offset_set(tf, offset)
    assert_equal offset, tf.to_find_parameters[:offset]
  end
  
end