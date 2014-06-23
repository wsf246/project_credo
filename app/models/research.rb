class Research < ActiveRecord::Base
  default_scope order('score DESC')

  has_many :findings, dependent: :destroy
  belongs_to :user, foreign_key: "user_create_id"   		

  accepts_nested_attributes_for :findings, 
  reject_if:	lambda { |a| a[:finding].blank?},
  	allow_destroy:  true  		  	  		    	
  validates :title, presence: true	
  validates :link, presence: true	

  def score_it
    score = (self.retracted ? 0 : 1) * (
    0 * (self.study_type == 'Unknown' ? 1 : 0) +
    2 * (self.study_type =='Case Study' ? 1 : 0) +          
    3 * (self.study_type == 'Cross-sectional' ? 1 : 0) +
    5 * (self.study_type == 'Case-control' ? 1 : 0) +
    8 * (self.study_type == 'Cohort Study' ? 1 : 0) +    
    13 * (self.study_type == 'Randomized Control Trial' ? 1 : 0) +

    2 * (self.funding.present? ? 1 : 0) +

    10 * (self.peer_reviewed ? 1 : 0) +
    10 * (self.replicated ? 1 : 0) + 

    1 * (self.single_blinded ? 1 : 0) + 
    1 * (self.double_blinded ? 1 : 0) + 
    1 * (self.randomized ? 1 : 0) +
    1 * (self.controlled_against_placebo ? 1 : 0) + 
    1 * (self.controlled_against_best_alt ? 1 : 0))
    self.update(score: score)
  end  
end
