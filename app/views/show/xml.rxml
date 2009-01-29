xml.instruct!

xml.list do 
  xml.id @list.id
  xml.name @list.name
  xml.details @list.details
  xml.url list_url(:id => @list.id)
  
  @errors.each do |error|
  	xml.error error
  end
  
  @talks.each do |talk|
    xml.talk do
      xml.id talk.id
      xml.title talk.title
      xml.abstract talk.abstract
      xml.speaker talk.name_of_speaker
      xml.venue talk.venue.name
      xml.special_message talk.special_message
      xml.url talk_url(:id => talk.id )
      
      xml.start_time talk.start_time.to_formatted_s(:rfc822)
      xml.end_time talk.end_time.to_formatted_s(:rfc822)
      xml.series talk.series.name
      
      if talk.created_at && talk.updated_at      
        xml.created_at talk.created_at.to_formatted_s(:rfc822)
        xml.updated_at talk.updated_at.to_formatted_s(:rfc822)
      end
    end
  end
end