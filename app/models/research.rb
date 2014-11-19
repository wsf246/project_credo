class Research < ActiveRecord::Base
  has_paper_trail :skip => [:updated_at, :created_at, :score, :user_create_id]
  default_scope { order('score DESC') }

  has_many :findings, dependent: :destroy
  belongs_to :user, foreign_key: "user_create_id"   		

  accepts_nested_attributes_for :findings,
  	allow_destroy: true
    		  	  		    	
  validates :title, presence: true	
  validates :link, presence: true	

  def self.score_weights
    {
      'Unknown' => 0.0,
      'Case Study'=> 2.0,
      'Cross Sectional'=> 3.0, 
      'Case Control' => 5.0,
      'Cohort Study' => 8.0,
      'Clinical Trial' => 13.0,
      'Review of Literature' => 21.0,
      'Randomized Control Trial' => 21.0,
      'Meta-Analysis' => 34.0,
      'Study Max' => 34.0,

      'Funding' => 4.0,

      'Peer Reviewed' => 10.0,
      'Replicated' => 10.0,
      'Verification Total' => 20.0,

      'Bias Control' => 1.5,
      'Bias Controls Total' => 7.5,
    }
  end

  def true_pos
    0.0249*Math.log(self.score) +0.8005
  end

  def false_pos
    -0.132*Math.log(self.score) +0.5999
  end    

  def score_it
    score = 
    (self.retracted ? 0 : 1) * 
    Research.score_weights[self.study_type] +

    Research.score_weights["Funding"] * (self.funding.present? ? 1 : 0) +

    Research.score_weights['Peer Reviewed'] * (self.peer_reviewed ? 1 : 0) +
    Research.score_weights['Replicated'] * (self.replicated ? 1 : 0) + 

    Research.score_weights['Bias Control'] *(
      (self.single_blinded ? 1 : 0) + 
      (self.double_blinded ? 1 : 0) + 
      (self.randomized ? 1 : 0) +
      (self.controlled_against_placebo ? 1 : 0) + 
      (self.controlled_against_best_alt ? 1 : 0)
    )
 
    self.update(score: score)
  end 

end

