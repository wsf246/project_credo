class Question < ActiveRecord::Base
  has_paper_trail :skip => [:updated_at, :slug, :created_at, :user_create_id, :cached_votes_total, :cached_votes_up,:cached_votes_down]

  extend FriendlyId
  friendly_id :question, use: [:slugged, :history]

  def should_generate_new_friendly_id?
    question_changed?
  end
  
  has_many :points, dependent: :destroy
  has_many :verdicts, dependent: :destroy
  belongs_to :user, foreign_key: "user_create_id"
  validates :question, presence: true, uniqueness: true	
  validates :question_type, presence: true 
  acts_as_votable  
  accepts_nested_attributes_for :verdicts, 
  reject_if:  lambda { |a| a[:verdict].blank?},
    allow_destroy:  true  

  default_scope { order('(questions.cached_votes_up-questions.cached_votes_down)*questions.cached_votes_total DESC') }



end
