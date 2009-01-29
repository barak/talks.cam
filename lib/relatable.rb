module Relatable
    
    def self.append_features(base)
      super
      base.class_eval do
        has_many :related_lists, :as => :related, :dependent => :destroy, :order => 'score DESC', :include => :list
        has_many :related_talks, :as => :related, :dependent => :destroy, :order => 'score DESC', :include => :talk
        after_create :create_related
      end 
    end 
    
    def create_related
      RelatedTalk.create_for self
      RelatedList.create_for self
      return true # just being cautious
    end 
      
end