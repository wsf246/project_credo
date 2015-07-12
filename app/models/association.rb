class Association < ActiveRecord::Base
  has_paper_trail :skip => [:updated_at, :created_at]

	belongs_to :question
	belongs_to :research

end
