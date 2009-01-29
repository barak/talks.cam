require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < Test::Unit::TestCase
  
  def test_data
    # Add a gif file
    image_file = File.open(gif_image,'r')
    image_file.extend FileCGICompatability
    image = Image.create :data => image_file
    image_file.close
    
    # As it was, but as a png
    image_recreated = image.to_magick
    assert_equal 'PNG', image_recreated.format
    assert_equal 18, image_recreated.rows
    assert_equal 53, image_recreated.columns
    
    # Smaller
    image_resized = image.to_magick('53x9')
    assert_equal 9, image_resized.rows
    assert_equal 27, image_resized.columns  
    
    # Larger
    image_resized = image.to_magick('106x106')
    assert_equal 36, image_resized.rows
    assert_equal 106, image_resized.columns
  end
  
  def test_no_data
    image = Image.new
    assert_equal nil, image.to_magick
    assert_equal false, image.valid?
    assert_equal false, image.save
    assert image.errors.on(:data)
  end
  
end
