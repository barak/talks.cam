module ShowHelper
  def body_class
    'list'
  end
  
  def upcoming_link
    # Have to use Talk.count rather than @list.talks.count since Ruby 1.8.7 as it seems to call Array.count instead :(
    count = pluralize( Talk.count(:distinct => true, :select => 'talk_id', :joins => "INNER JOIN list_talks ON talks.id = list_talks.talk_id", :conditions => ['(list_talks.list_id = ?) AND (start_time >= ?)', @list.id, Time.now.at_beginning_of_day ] ), 'upcoming talk')
    unless request.request_uri == list_url( :id => @list.id, :only_path => true  )
      link_to count, list_url( :id => @list.id )
    else
      "<b>#{count}</b>"
    end
  end
  
  def archive_link
    max = 500
    # Have to use Talk.count rather than @list.talks.count since Ruby 1.8.7 as it seems to call Array.count instead :(
    countno = Talk.count( :distinct => true, :select => 'talk_id', :joins => "INNER JOIN list_talks ON talks.id = list_talks.talk_id", :conditions => ['(list_talks.list_id = ?) AND (start_time < ?)', @list.id, Time.now.at_beginning_of_day ] )
    count = "#{pluralize(countno, 'talk')} in the archive"
    unless request.request_uri == archive_url( :id => @list.id, :only_path => true  )
      if countno > max && request.request_uri != archive_url( :id => @list.id, :limit => max, :only_path => true )
        link_to count+": show first #{max}", archive_url( :id => @list.id, :limit => max )
      else
        link_to count+"#{ countno > max ? ': show all (slow!)' : '' }", archive_url( :id => @list.id )
      end
    else
       "<b>#{count}</b>"
    end
  end
  
  def usual_details( threshold = 0.75 )
    return @usual_details if @usual_details
    threshold = @talks.size * threshold
    @usual_details = {:name_of_speaker => nil, :series => nil, :start_time => nil, :venue_name => nil, :time_slot => nil}
    @usual_details.keys.each do |parameter|
      values = {}
      @talks.each do |talk|
        value = talk.send(parameter)
        values[value] = (values[value] || 0) + 1 
      end
      sorted_values = values.sort_by { |k,v| v }
      if sorted_values.last.last >= threshold
        @usual_details[parameter] = sorted_values.last.first
      end
    end
    @usual_details
  end

  def unusual?(talk,parameter)
    talk.send(parameter) != usual_details[parameter]
  end
  
  # FIXME: Refactor
  def term_string( term )
    case term.first.mon
    when 1..3 # Lent term
      "Lent Term #{term.first.year}"
    when 4..6 # Easter term
      "Easter Term #{term.first.year}"
    when 7..9 # Long vac.
      "Long Vacation #{term.first.year}"
    when 10..12 # Michaelmas term
      "Michaelmas Term #{term.first.year}"
    end  
  end
  
  def cam_time_format( timestring )
    timestring.downcase.gsub(/0(?=\d\.)/,'').gsub(/\.00/,'')
  end
  
end
	
