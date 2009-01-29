# This is some glue between the parameters sent and a Talk finder request
class TalkFinder
  
  attr_accessor :conditions, :settings, :find_parameters, :order, :offset, :limit, :errors
  
  def initialize(parameters = {})
    self.conditions, self.settings, self.find_parameters = [], [], {}
    self.errors = []
    parameters.each do |key,value|
      send("#{key}=", value) if self.respond_to?("#{key}=")
    end
  end
  
  def to_find_parameters
    set_default_conditions
    set_default_order
    find_parameters[:conditions] = [ conditions.join(' AND '), *settings ]
    find_parameters[:order] = order
    find_parameters[:offset] = offset if offset
    find_parameters[:limit] = limit if limit
    find_parameters
  end
  
  def seconds_before_today=(period)
  	begin
	    set start_time_greater, beginning_of_day - period.to_i
    rescue RangeError
    	# The time string in the URL could not be converted.  Record an error and ignore parameter.  
    	errors << "Seconds before today was out of range in the request"
    end
  end
  
  def seconds_after_today=(period)
  	begin 
	    set start_time_less, beginning_of_day + period.to_i
    rescue RangeError
    	# The time string in the URL could not be converted.  Record an error and ignore the parameter.  
    	errors << "Seconds after today was out of range in the request"
    end
  end
  
  def start_seconds=(time)
  	begin 
    	set start_time_greater, Time.at(time.to_i)
    rescue RangeError
    	# The time string in the URL could not be converted.  Record an error and ignore the start_time parameter.  
    	errors << "Start time was out of range in the request"
    end
  end
  
  def end_seconds=(time)
  	begin 
	    set start_time_less, Time.at(time.to_i)
    rescue RangeError
    	# The time string in the URL could not be converted.  Record an error and ignore the start_time parameter.  
    	errors << "End time was out of range in the request"    	
    end
  end
  
  alias :start_time= :start_seconds=
  alias :end_time= :end_seconds=
  
  def reverse_order=(reverse_order)
    self.order = 'start_time DESC' if reverse_order && reverse_order != ""
  end
  
  def term=(time)
    time = (time == 'current') ? Time.now : Time.at(time.to_i)
    term_dates =  case time.mon
                  when 1..3 # Lent term
                    month_range( time.year, 1, 3 )
                  when 4..6 # Easter term
                    month_range( time.year, 4, 6 )
                  when 7..9 # Long vac.
                    month_range( time.year, 7, 9 )
                  when 10..12 # Michaelmas term
                    month_range( time.year, 10, 12 )
                  end
    set 'start_time > ? AND start_time < ?', *term_dates
	end
	
	private
	    
  def set_default_conditions
    return unless conditions.empty?
    set start_time_greater, beginning_of_day
  end
  
  def set( condition, *setting)
    conditions << condition
    self.settings += setting
  end
  
  def set_default_order
    self.order = 'start_time ASC' unless self.order
  end
  
  def start_time_greater
    'start_time > ?'
  end
  
  def start_time_less
    'start_time < ?'
  end
  
  def beginning_of_day
    Time.now.at_beginning_of_day
  end
  
  def month_range( year, start_month, end_month )
	 return Time.local( year, start_month ).at_beginning_of_month, Time.local(year,end_month).at_end_of_month
	end
end