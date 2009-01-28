# Schema as of Sat Mar 18 21:01:28 GMT 2006 (schema version 9)
#
#  id                  :integer(11)   not null
#  name                :string(255)   
#  user_id             :integer(11)   
#  list_id             :integer(11)

require 'ostruct'

class CustomView < ActiveRecord::Base
  belongs_to :user
  belongs_to :list
  
  serialize :view_parameters
    
  def self.layout_options
    [ 
      ['In a talks.cam webpage, with the default look','with_related'],
      ['In a talks.cam webpage, with a minimal header and footer','minimal'],
      ['For embedding in your web page (you provide the css)','embed'],
      ['For embedding in your web page (we provide the css)','embedcss'],
      ['With nothing (handy for xml, rss, ical etc)','empty']
    ]
  end
  
  def self.action_options
    [ 
      ['Default look','index'],
      ['Compatible with old talks listing','old_talks'],
      ['Laid out as a table','table'],
      ['Minimalist look','minimalist'],
      ['All the details about every talk','detailed'],
      ['Basic details with series logos next to each talk','simplewithlogo'],
      ['For one day meetings: no venue or dates','oneday'],
      ['Printable bulletin style (e.g. for cutting and pasting into Word)','bulletin'],
      ['As plain text (e.g. for cutting and pasting into email)','text'],
      ['XML','xml'],
      ['RSS','rss'],
      ['iCalendar','ics'],
    ]
  end
  
  def self.time_periods
    [
      ['No limit', nil],
      ['day', 1.day],
      ['week', 1.week],
      ['Two weeks', 1.weeks],
      ['month', 1.month],
      ['Two months', 2.months],
      ['Three months', 3.months],
      ['Year', 1.year],
    ]
  end
  
  def view_struct
    OpenStruct.new( view_parameters || {})
  end
  
end
