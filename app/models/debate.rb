class Debate < ActiveRecord::Base
  default_scope -> { order('created_at DESC') }
  validates :title, presence: true	
end
