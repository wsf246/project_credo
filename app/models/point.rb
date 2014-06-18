class Point < ActiveRecord::Base
	has_many :associations, dependent: :destroy
    has_many :findings, through: :associations	
	belongs_to :debate
	validates :debate_id, presence: true
	validates_inclusion_of :for_against, in: [true,false]
	validates :point, presence: true, uniqueness: true
  acts_as_votable

  def associated?(finding)
    associations.find_by(finding_id: finding.id)
  end

  def associate!(finding)
    associations.create!(finding_id: finding.id)
  end

  def unassociate!(finding)
  	associations.find_by(finding_id: finding.id).destroy
  end
end
