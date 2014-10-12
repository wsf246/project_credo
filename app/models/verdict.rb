class Verdict < ActiveRecord::Base
  default_scope { order('cached_votes_total DESC') }
  acts_as_votable 
  belongs_to :question
  validates :verdict, presence: true
  validates :short, presence: true
  validates :short, length: {   
      maximum: 140,
      too_long: "%{count} characters is the maximum allowed" 
    }
  belongs_to :user, foreign_key: "user_create_id" 

  def vote_score
    (self.cached_votes_up-self.cached_votes_down)*self.cached_votes_total
  end  
end
