module CustomViewHelper
  
  def keep_url_in_sync_with_form( cview, form = 'viewform', urldiv = 'viewurl')
    observe_form form,  {   :url => { :action => 'update', :id => cview }, 
                            :update => urldiv,
                            :loading => "Element.update('#{urldiv}','Updating the link');",
                            :complete => "new Effect.Highlight('#{urldiv}');"
                        }
  end
  
end
