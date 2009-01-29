require File.dirname(__FILE__) + '/../spec_helper'

context "Time has a to_s(:ics) format" do
    specify "that produces YYYYMMDDTHHMMSSZ" do
      Time.local(2007,01,01,10,10,10).to_s(:ics).should_be == "20070101T101010Z"
    end
end

context "A String has a to_ics method" do
  
  specify "that escapes \\" do
    'Hello \\ world'.to_ics.should_be == "Hello \\\\ world"
  end
  
  specify "that escapes ;" do
    'Hello; world'.to_ics.should_be == "Hello\\; world"
  end
  
  specify "that escapes ," do
    'Hello, world'.to_ics.should_be == "Hello\\, world"
  end
  
  specify 'that escapes \n' do
    "Hello\n world".to_ics.should_be == "Hello\\n world"
  end
  
  specify 'that escapes \r\n' do
    "Hello\r\n world".to_ics.should_be == "Hello\\n world"
  end
  
  specify 'that converts long text into several shorter lines' do
    ("1234567890"*10).to_ics.should_be == "12345678901234567890123456789012345678901234567890\r\n 12345678901234567890123456789012345678901234567890"
  end
  
end

context "Array has a to_ics method" do
  
  specify "That calls to_ics on each of its members" do
    array = []
    3.times do
      array << m = mock('thing')
      m.should_receive(:to_ics)
    end
    array.to_ics
  end
  
  specify "That wraps its memebers in the VCALENDAR header and footer" do
    array = [m = mock('thing')]
    m.should_receive(:to_ics).and_return("BEGIN:VEVENT\r\nEND:VEVENT")
    icalendar = 
"BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//talks.cam.ac.uk//v3//EN\r\nBEGIN:VEVENT\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n"
    array.to_ics.should_be == icalendar
  end
  
end
