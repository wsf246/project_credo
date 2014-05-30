class Finding < ActiveRecord::Base
  belongs_to :research	
  has_many :associations, :dependent => :destroy
  has_many :points, :through => :associations	  	
end
