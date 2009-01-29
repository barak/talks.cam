require File.dirname(__FILE__) + '/../test_helper'
require 'mailer'

class MailerTest < Test::Unit::TestCase
  CHARSET = "utf-8"
  include ActionMailer::Quoting
  fixtures :users, :lists, :talks, :list_lists, :list_talks, :email_subscriptions, :tickles
  
  def setup
    Mailer.deliveries.clear
  end

  def test_password
    message = Mailer.create_password( users(:vic), 'http://test.url' )
    assert_equal "Your talks.cam password", message.subject
    assert_equal users(:vic).email, message.to[0]
    assert_equal "noreply@talks.cam.ac.uk", message.from[0]
    assert_match "password: #{users(:vic).password}", message.body
  end
  
  def test_speaker_invite
    talk = talks(:one)
    user = users(:vic)
    message = Mailer.create_speaker_invite(user,talk)
    assert_equal  "Giving a talk in Cambridge", message.subject
    assert_equal "noreply@talks.cam.ac.uk", message.from[0]
    assert_equal user.email, message.to[0]
    assert_equal talk.organiser.email, message.cc[0]
    assert_match talk.series.name, message.body
    assert_match talk.title, message.body
  end
  
  def test_tickle
    message = Mailer.create_talk_tickle( tickles(:one) )
    assert_equal "[Talks.cam] A talk that you might be interested in", message.subject
    assert_equal "noreply@talks.cam.ac.uk", message.from[0]
    assert_match talks(:one).title, message.body
    
    message = Mailer.create_list_tickle( tickles(:two) )
    assert_equal "[Talks.cam] A list that you might be interested in", message.subject
    assert_equal "noreply@talks.cam.ac.uk", message.from[0]
    assert_match lists(:one).name, message.body
  end
  
  def test_send_daily_list
    Mailer.send_daily_list
    EmailSubscription.find(:all).each do |subscription|
      mail = Mailer.deliveries.find { |mail| mail.to[0] == subscription.user.email }
      talks_in_mail = subscription.list.talks.find(:all,:conditions => ['start_time > ? AND start_time < ?',Time.now.at_beginning_of_day,Time.now.at_beginning_of_day+1.day])
      if talks_in_mail.empty?
        assert !mail
      else
        assert mail
      end
    end
  end
  
  def test_send_weekly_list
    Mailer.send_weekly_list
    EmailSubscription.find(:all).each do |subscription|
      mail = Mailer.deliveries.find { |mail| mail.to[0] == subscription.user.email }
      talks_in_mail = subscription.list.talks.find(:all,:conditions => ['start_time > ? AND start_time < ?',Time.now.at_beginning_of_day,Time.now.at_beginning_of_day+1.week])
      if talks_in_mail.empty?
        assert !mail
      else
        assert mail
      end
    end
  end
  
  def test_daily_list
    # Create the subscription
    list = create_test_list
    talks = list.talks.find( :all, :conditions => [ 'start_time >= ? AND start_time <= ?', Time.now.at_beginning_of_day, Time.now.at_beginning_of_day + 1.day] )
    user = users(:vic)
    subscription = EmailSubscription.create :user => user, :list => list
    
    # Create and check the message
    message = Mailer.create_daily_list( subscription )
    assert_equal "[Talks.cam] Today's talks: #{list.name}", message.subject
    check_message message, user, list, talks
  end

  def test_weekly_list
    # Create the subscription
    list = create_test_list
    talks = list.talks.find( :all, :conditions => [ 'start_time >= ? AND start_time <= ?',Time.now.at_beginning_of_day, Time.now.at_beginning_of_day + 1.week ])
    user = users(:vic)
    subscription = EmailSubscription.create :user => user, :list => list
    
    # Create and check the message
    message = Mailer.create_weekly_list( subscription )
    assert_equal "[Talks.cam] This week's talks: #{list.name}", message.subject
    check_message message, user, list, talks
  end

  private
    
  def create_test_list
    list = List.create :name => 'Test list'
    Talk.find(:all).each { |talk| list.add(talk) }
    list
  end
  
  def check_message( message, user, list, talks)
    # Test the wrapping
    assert_equal user.email, message.to[0]
    assert_equal "noreply@talks.cam.ac.uk", message.from[0]
    assert_equal 1, message.parts.size
    
    # Test the plain body
    plain_text = message.parts.first.body
    # Test including the talks we want
    talks.each do |talk|
      assert_match talk.title.upcase, plain_text
    end
    # Test excluding the talks we don't want
    excluded_talks = list.talks.to_a - talks
    excluded_talks.each do |talk|
      assert_no_match /#{talk.title.upcase}/, plain_text
    end
    
  end
  
    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end