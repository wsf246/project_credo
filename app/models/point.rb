class Point < ActiveRecord::Base
  has_paper_trail :skip => [:updated_at, :created_at, :user_create_id, :cached_votes_total, :cached_votes_up,:cached_votes_down]
  has_many :associations, dependent: :destroy
  has_many :findings, through: :associations
	belongs_to :question
  belongs_to :user, foreign_key: "user_create_id"   
	validates :question_id, presence: true
  validates :point_type, presence: true
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

  def self.to_csv
    CSV.generate do |csv|
      csv << ["Evidence Group","Created On", "Evidence Group Votes", 
      "Research Paper", "Finding", "Pub Date",
      "Study Type", "Retracted", "Peer Reviewed", "Replicated", 
      "Funding", "Single Blinded", "Double Blinded",
      "Randomzied", "Control Placebo", "Control Alt",
      "Score"]
      all.each do |point|
        point.findings.all.each do |finding|
         csv << [point.point, point.created_at, point.cached_votes_total,
          finding.research.title, finding.finding, finding.research.date_of_publication,
          finding.research.study_type,finding.research.retracted, finding.research.peer_reviewed, finding.research.replicated,
          finding.research.funding, finding.research.single_blinded, finding.research.double_blinded,
          finding.research.randomized, finding.research.controlled_against_placebo, finding.research.controlled_against_best_alt,
          finding.research.score]
        end
      end
    end
  end

  def vote_score
    (self.cached_votes_up-self.cached_votes_down)*self.cached_votes_total
  end
end
