class Image < ActiveRecord::Base
  
  validates_length_of :data, :within => 1...1.1.megabytes
  
  def data=(file)
    if file.size > 0 && file.size < 1.megabyte
      img = Magick::Image.from_blob(file.read)[0]
      img.format = 'PNG'
      self[:data] = img.to_blob
    end
    GC.start
  end
  
  def to_magick( geometry = nil )
    return nil unless data
    magick = Magick::Image.from_blob(data)[0]
    magick.change_geometry!(geometry) { |cols, rows, image| image.resize!(cols, rows) } if geometry
    GC.start
    magick
  end

end
