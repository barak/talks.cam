class ImageController < ApplicationController
  
  caches_page :show
  
  def show
    magick = Image.find(params[:id]).to_magick(params[:geometry])
    headers['Cache-Control'] = 'public'
    if magick
      send_data(magick.to_blob, :type => magick.mime_type, :disposition => 'inline')
    else
       render :text => "No data in image", :status => 404
    end
  end
end
