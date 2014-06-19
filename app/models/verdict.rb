class Verdict < ActiveRecord::Base
  default_scope order('cached_votes_total DESC')  
  acts_as_votable 
  belongs_to :debate
  validates :verdict, presence: true    
end
