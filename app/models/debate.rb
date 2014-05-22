class Debate < ActiveRecord::Base
  has_many :points, dependent: :destroy
  default_scope -> { order('created_at DESC') }
  validates :title, presence: true	
end
