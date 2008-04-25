require File.dirname(__FILE__) + '/../test_helper'

class ShowHelperTest < Test::Unit::TestCase
  include ShowHelper
  
  def setup
    @venueA = Venue.create :name => 'Venue A'
    @venueB = Venue.create :name => 'Venue B'
    @seriesA = List.create :name => 'Series A'
    @seriesB = List.create :name => 'Series B'
    @speakerA, @speakerB = "Speaker A", "Speaker B"
    @start_timeA, @start_timeB = 1.hour.ago, Time.now.next_week
    @talksA, @talksB = [], []
    1.upto(12) do |number|
      @talksA << Talk.create(:title => "Talk #{number}", 
                            :name_of_speaker => @speakerA,
                            :venue => @venueA,
                            :series => @seriesA,
                            :start_time => @start_timeA,
                            :end_time => @start_timeA + 1.hour
                            )
    end
    13.upto(15) do |number|
      @talksB << Talk.create(:title => "Talk #{number}", 
                            :name_of_speaker => @speakerB,
                            :venue => @venueB,
                            :series => @seriesB,
                            :start_time => @start_timeB,
                            :end_time => @start_timeB + 45.minutes
                            )
    end
    @talks = @talksA + @talksB
  end
  
  def test_below_threshold
    @usual_details = nil
    assert_equal( {:name_of_speaker => nil, :series => nil, :start_time => nil, :venue_name => nil, :time_slot => nil }, usual_details(0.9))
  end
  
  def test_usual_details
    @usual_details = nil
    assert_equal( {:name_of_speaker => @speakerA, :series => @seriesA, :start_time => @start_timeA, :venue_name => @venueA.name, :time_slot => @talksA.first.time_slot }, usual_details)
  end
  
  def test_unusual
    @talksA.each do |talk|
      [:name_of_speaker, :series, :start_time, :venue_name, :time_slot].each do |parameter|
        assert_equal false, unusual?( talk, parameter )
      end
    end
    @talksB.each do |talk|
      [:name_of_speaker, :series, :start_time, :venue_name, :time_slot].each do |parameter|
        assert_equal true, unusual?( talk, parameter )
      end
    end
  end
  
  def test_term_convertor
    [2004,2005,2006].each do |year|
      lent = [ Time.local( year,1,1), Time.local(year,3,31) ]
      easter = [ Time.local( year,4,1), Time.local(year,6,30) ]
      vacation = [ Time.local( year,7,1), Time.local(year,9,30) ]
      michaelmas = [ Time.local( year,10,1), Time.local(year,12,31) ]
      
      assert_equal "Michaelmas Term #{year}", term_string( michaelmas )
      assert_equal "Lent Term #{year}", term_string( lent )
      assert_equal "Easter Term #{year}", term_string( easter )
      assert_equal "Long Vacation #{year}", term_string( vacation )
    end
  end
  
end