class CustomViewController < ApplicationController
  
  before_filter :find_custom_view, :except => ['embed_example','embed_example2','embed_example3','embed_example4','embed_example5','update','old_embed_feed','old_show_series','old_show_listing']
  
  def embed_example
    @url = params[:url]
    render :layout => false
  end
  
  alias :embed_example2 :embed_example
  alias :embed_example3 :embed_example
  alias :embed_example4 :embed_example
  alias :embed_example5 :embed_example    
  
  def old_embed_feed
    custom_view = CustomView.find_by_old_id @params[:id]
    #render_component options_hash( custom_view, {:controller => 'show', :id => custom_view.list_id, 'suffix' => @params[:suffix]} )
    redirect_to url_for_view( custom_view, {'suffix' => @params[:suffix]})
  end
  
  def old_show_listing
    listing = Listing.find_by_old_id @params[:id]
    redirect_to list_url(:id => listing)
  end
  
  def old_show_series
    list = List.find_by_old_id @params[:id]
    redirect_to list_url(:id => list )
  end
  
  def find_custom_view
    @custom_view = if @params[:id]
      CustomView.find @params[:id]
    else
      CustomView.new :list => List.find(params[:list]), :view_parameters => {}
    end
    @list = @custom_view.list
    @view_parameters = @custom_view.view_struct
  end
  
  def update
    unless params[:view_parameters]
      render :text => "If you see this message and you aren't a search engine, please contact webmaster@talks.cam.ac.uk", :status => 404
      return
    end
    convert_date_parameters    
    url_area CustomView.new( :list_id => params[:custom_view][:list_id], :view_parameters => params[:view_parameters] )
  end
  
  # Make this method available in the view class
  helper_method :url_area
  
  def url_area( custom_view )
    partial = case custom_view.view_parameters['layout']
              when 'embed','embedcss'
                'embed_url'
              else
                'url'
              end 
      render  :partial => partial, :locals => {:custom_view => custom_view}
  end
  
  helper_method :url_for_view
  
  def url_for_view( custom_view, extra_options = {} )
    unless ( custom_view != nil )
      return list_url(:id => 'notfound404')
    end
    list_url( options_hash( custom_view, { :only_path => false,:id => custom_view.list_id }.merge(extra_options)) )
  end
  
  def options_hash( custom_view, options = {})
    options.merge! custom_view.view_parameters
    options.delete_if { |key,value| value.is_a?(String) && value.empty? }
    options.delete('limit') unless custom_view.view_parameters['limit_numbers'] == '1'
    options.delete('seconds_before_today') unless custom_view.view_parameters['limit_period'] == '1'
    options.delete('seconds_after_today') unless custom_view.view_parameters['limit_period'] == '1'
    options.delete 'limit_numbers'
    options.delete 'limit_date'
    options.delete 'limit_period'
    options[:action] = options['action']
    options[:layout] = options['layout']
    options
  end
  
  def convert_date_parameters
    @params[:view_parameters]['start_time'] = convert_date_parameter('start_time')
    @params[:view_parameters]['end_time'] = convert_date_parameter('end_time')
  end
  
  def convert_date_parameter( parameter )
    date = [ @params[:view_parameters].delete("#{parameter}(1i)"), @params[:view_parameters].delete("#{parameter}(2i)"), @params[:view_parameters].delete("#{parameter}(3i)") ]
    date.delete_if { |string| string.empty? }
    return "" if date.empty?
    date.map { |string| string.to_i }
    Time.local(*date).to_i
  end
  
end
