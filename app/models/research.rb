class Research < ActiveRecord::Base
  has_many :quotes, dependent: :destroy	
  has_many :findings, dependent: :destroy		
  has_many :sample_defs, dependent: :destroy
  accepts_nested_attributes_for :quotes, 
  :reject_if =>	lambda { |a| a[:quote].blank?},
  	:allow_destroy =>  true
  accepts_nested_attributes_for :findings, 
  :reject_if =>	lambda { |a| a[:finding].blank?},
  	:allow_destroy =>  true 
  accepts_nested_attributes_for :sample_defs, 
  :reject_if =>	lambda { |a| a[:sample_def].blank?},
  	:allow_destroy =>  true   	  	 		  	  		    	
  validates :title, presence: true		
end
