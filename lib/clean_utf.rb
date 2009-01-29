require 'iconv'

module CleanUtf
  
   def self.append_features(base)
      super
      base.class_eval do
        before_save :clean_utf
      end 
    end 
    
    # Clean up any mal-formatted utf in any string fields
    def clean_utf
      attribute_names.each do |field|
        next unless self[field]
        next unless self[field].is_a? String
        self[field] = Iconv.iconv('UTF-8//IGNORE','UTF-8',self[field]).first
      end
    end
end