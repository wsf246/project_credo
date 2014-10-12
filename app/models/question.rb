class Question < ActiveRecord::Base
  has_many :points, dependent: :destroy
  has_many :verdicts, dependent: :destroy
  belongs_to :user, foreign_key: "user_create_id"
  validates :question, presence: true, uniqueness: true	
  validates :question_type, presence: true 
  acts_as_votable  
  accepts_nested_attributes_for :verdicts, 
  reject_if:  lambda { |a| a[:verdict].blank?},
    allow_destroy:  true  

  default_scope { order('(cached_votes_up-cached_votes_down)*cached_votes_total DESC') }

  def vote_score
    ()
  end
end
