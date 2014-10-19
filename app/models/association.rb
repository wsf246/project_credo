class Association < ActiveRecord::Base
  has_paper_trail :skip => [:updated_at, :created_at]

	belongs_to :point
	belongs_to :finding
end
