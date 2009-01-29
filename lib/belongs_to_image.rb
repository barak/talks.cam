module BelongsToImage
  
  def self.append_features(base)
    super
    base.class_eval do # This gets executed as if it was in the class definition
      
      belongs_to :image # Make the model have an image object
      alias :image_object= :image= # Keep the old accessor, but change its name
      validates_associated :image, :message => 'is too big, or in an unrecognised format', :allow_nil => true

      # Override the accessor so can set with file data
      def image=(value)
        case value
        when Image
          self.image_object = value
        when nil, ''
          # Do nothing, leave the existing image.
        else
          self.image_object = Image.create(:data => value)
        end
      end
      
    end # class_eval
  end # append_features

end