class Finding < ActiveRecord::Base
  belongs_to :research
  has_many :associations, dependent: :destroy
  has_many :points, through: :associations
  validates :finding, presence: true
  validates :sample_def, presence: true
  validates :quote, presence: true 	  	
end
