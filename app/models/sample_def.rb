class SampleDef < ActiveRecord::Base
  belongs_to :research	
  validates :research_id, presence: true		
end
