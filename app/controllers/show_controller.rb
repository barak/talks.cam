class ShowController < ApplicationController
  
  # We do this to avoid creating numerous sessions for rss
  # feed requests, xml requests, e-mail requests etc.
  session :off, :if => Proc.new { |request| request.parameters[:layout] }
  
  layout :decode_layout
  before_filter :decode_time_period
  before_filter :decode_list_details
  
  # For plain text
  def text
    headers["Content-Type"] = "text/plain; charset=utf-8"
		render :layout => false
  end
  
  # For email
  def email
    headers["Content-Type"] = "text/plain; charset=utf-8"
    begin
		render :layout => false
    rescue Exception
                render :text => "Sorry, an error occured in producing your email.\n\nPlease contact the Helpdesk."
    end
  end
  
  # For watching as a feed
	def rss
		headers["Content-Type"] = "text/xml; charset=utf-8"
		render :layout => false
	end
	
  # For watching as a feed
	def xml
		headers["Content-Type"] = "text/xml; charset=utf-8"
		render :layout => false
	end
	
	# For download into a calendar	
	def ics
		headers["Content-Type"] = "text/calendar; charset=utf-8"
		render :text => @talks.to_ics
	end
	
	private
	
	def decode_layout
    params[:layout] || 'with_related'
  end
  
  def decode_time_period
    @list = List.find params[:id]
    finder = TalkFinder.new(params)
    @errors = finder.errors
    @talks = @list.talks.find( :all, finder.to_find_parameters)
  end
  
  # FIXME: Refactor so that can set this from url
  def decode_list_details
    @list_details = true
    true # Must return true for method to continue
  end	
end
