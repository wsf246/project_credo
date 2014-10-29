class Finding < ActiveRecord::Base
  has_paper_trail :skip => [:updated_at, :created_at]
  belongs_to :research
  has_many :associations, dependent: :destroy
  has_many :points, through: :associations
  validates :finding, presence: true
  validates :finding, uniqueness: true
  validates :sample_def, presence: true
  validates :quote, presence: true
  validates :quote, uniqueness: true  	  	
end
