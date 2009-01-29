ActionController::Routing::Routes.draw do |map|
  map.resources :tickles

  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.home '', :controller => "search"

  map.search 'search/:search', :controller => 'search', :action => 'results', :search => nil

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  map.date_index 'dates/:year/:month/:day', :controller => 'index', :action => 'dates', :year => Time.now.year.to_s, :month => Time.now.month.to_s, :day => Time.now.day.to_s, :requirements => {:year => /\d{4}/, :day => /\d{1,2}/,:month => /\d{1,2}/}  
  map.index 'index/:action/:letter', :controller => 'index', :action => 'lists', :letter => 'A'
  
  map.archive 'show/archive/:id', :controller => 'show', :action => 'index', :seconds_after_today => '0', :reverse_order => true
  map.list 'show/:action/:id', :controller => 'show', :action => 'index'
  map.list_user 'list/:list_id/managers/:action', :controller => 'list_user', :action => 'index'
  map.list_details 'list/:action/:id', :controller => 'list', :action => 'index'

  map.new_user 'user/new', :controller => 'user', :action => 'new'
  map.user 'user/:action/:id', :controller => 'user', :action => 'show'
  map.talk 'talk/:action/:id', :controller => 'talk', :action => 'index'
  map.login 'login/:action', :controller => 'login', :action => 'index'
  map.reminder 'reminder/:action/:id', :controller => 'reminder', :action => 'index'
  map.include_list '/include/list/:action/:id', :controller => 'list_list', :action => 'create'
  map.include_talk '/include/talk/:action/:id', :controller => 'list_talk', :action => 'create'
  
  # Sort out the image controller
  map.with_options :controller => 'image', :action => 'show' do |image_controller|
    image_controller.connect '/image/:action/:id/image.png'
    image_controller.picture   '/image/:action/:id/image.png;:geometry', :geometry => '128x128'
  end
  
  # Map the old embedded feeds
  map.connect 'external/embed_feed.php', :controller => 'custom_view', :action => 'old_embed_feed'
  map.connect 'directory/show_series.php', :controller => 'custom_view', :action => 'old_show_series'
  map.connect 'external/feed.php', :controller => 'custom_view', :action => 'old_show_listing'
  
  map.document_index 'document/index', :controller => 'document', :action => 'index'
  map.connect 'document/changes', :controller => 'document', :action => 'recent_changes'
  map.document 'document/:name/:action', :controller => 'document', :action => 'show', :name => 'Home Page', :requirements => { :name => /[^\/]*/i }

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
