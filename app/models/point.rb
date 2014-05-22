class Point < ActiveRecord::Base
	has_many :findings
	belongs_to :debate
	validates :debate_id, presence: true
	validates_inclusion_of :for_against, in: [true,false]
	validates :point, presence: true, uniqueness: true

end
