# Specify a custom time format for icalendar
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:ics => '%Y%m%dT%H%M%SZ')

# Specify a custom string format for icalendar
class String
  
  def to_ics
    # Escape the characters we need
    ical = self.dup
    [ ["\\","\\\\\\"],[/\r\n/,'\n' ],[/\n/,'\n' ],[',','\,'],[';','\;'] ].each do |substition|
      ical.gsub! *substition
    end
    # Shorten the text to less than 50 characters
    ical.scan(/.{1,50}/).join("\r\n ")
  end
  
end

# Add a to_ical to the Array class

class Array
  
  def to_ics
    ("BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//talks.cam.ac.uk//v3//EN\r\n" +
    map {|element| element.to_ics }.join("\r\n") +
    "\r\nEND:VCALENDAR\r\n")
  end
end