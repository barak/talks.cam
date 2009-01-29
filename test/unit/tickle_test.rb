require File.dirname(__FILE__) + '/../test_helper'

class TickleTest < Test::Unit::TestCase
  fixtures :tickles, :users, :lists, :talks

  def test_polymorphic
    tickle = Tickle.create :about => talks(:one)
    assert_equal(talks(:one), tickle.about)
    tickle = Tickle.create :about => lists(:one)
    assert_equal(lists(:one), tickle.about)
  end
  
  def test_sender
    tickle = Tickle.create :sender => users(:vic)
    assert_equal(users(:vic), tickle.sender)
  end
  
  def test_create_sender_email_and_name_from_sender
    tickle = Tickle.create :sender => users(:vic)
    assert_equal(users(:vic).name, tickle.sender_name)
    assert_equal(users(:vic).email, tickle.sender_email)
  end
  
  def test_sends_message_after_create
    # Talk
    Mailer.deliveries.clear
    recipient_email = 'someone@talks.cam.ac.uk'
    tickle = Tickle.create! :sender => users(:vic), :about => talks(:one), :recipient_email => recipient_email
    assert Mailer.deliveries.find { |mail| mail.to && (mail.to[0] == recipient_email ) }
    
    # List
    Mailer.deliveries.clear
    tickle = Tickle.create! :sender => users(:vic), :about => lists(:one), :recipient_email => recipient_email
    assert Mailer.deliveries.find { |mail| mail.to && (mail.to[0] == recipient_email ) }
  end
  
  def test_requires_a_sender_name_and_email
    tickle = Tickle.create :sender_name => 'someone'
    assert_equal(false, tickle.save)
    assert tickle.errors.on(:sender_email)

    tickle = Tickle.create :sender_email => 'someone@talks.cam.ac.uk'
    assert_equal(false, tickle.save)
    assert tickle.errors.on(:sender_name)
  end
  
  def test_requires_valid_recipient_email
    tickle = Tickle.create :recipient_email => 'not a valid email'
    assert_equal(false, tickle.save)
    assert tickle.errors.on(:recipient_email)
  end
  
  def test_cant_send_the_same_thing_to_the_same_person_twice
    recipient_email = 'someone@talks.cam.ac.uk'
     tickle = Tickle.create! :sender => users(:vic), :about => talks(:two), :recipient_email => recipient_email
     tickle2 = Tickle.create :sender => users(:jim), :about => talks(:two), :recipient_email => recipient_email
     assert_equal(false, tickle2.save)
     assert tickle2.errors.on(:recipient_email)
  end
  
  def test_no_more_than_ten_from_the_same_ip_per_hour
    1.upto(10) { |i| Tickle.create!(:recipient_email => "#{i}@recipient.com", :sender_ip => '127.1.1.23.123.12', :sender => users(:vic)) }
    tickle = Tickle.create :sender_ip => '127.1.1.23.123.12', :recipient_email => "11@recipient.com", :sender => users(:vic)
    assert_equal(false, tickle.save)
    assert tickle.errors.on(:sender_ip)
  end
  
end
