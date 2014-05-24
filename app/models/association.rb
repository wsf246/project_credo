class Association < ActiveRecord::Base
	belongs_to :point
	belongs_to :finding
end
