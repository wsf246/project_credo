class Finding < ActiveRecord::Base
  belongs_to :research	
  belongs_to :point	  	
  validates :research_id, presence: true		
end
