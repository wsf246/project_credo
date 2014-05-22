class Research < ActiveRecord::Base
  has_many :findings, dependent: :destroy		

  accepts_nested_attributes_for :findings, 
  :reject_if =>	lambda { |a| a[:finding].blank?},
  	:allow_destroy =>  true  		  	  		    	
  validates :title, presence: true		
end
