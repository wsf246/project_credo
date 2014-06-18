class Debate < ActiveRecord::Base
  has_many :points, dependent: :destroy
  default_scope -> { order('cached_votes_total DESC') }
  validates :title, presence: true	
  acts_as_votable  
end
