class Research < ActiveRecord::Base
  has_many :findings, dependent: :destroy		

  accepts_nested_attributes_for :findings, 
  :reject_if =>	lambda { |a| a[:finding].blank?},
  	:allow_destroy =>  true  		  	  		    	
  validates :title, presence: true	
  validates :link, presence: true	

  def cool
    print
    10+
    1* if self.peer_reviewed then 1 else 0 end 
    + 1* if self.replicated then 1 else 0 end 
    + 1* if self.retracted then 1 else 0 end
    + 1* if self.single_blinded then 1 else 0 end 
    + 1* if self.double_blinded then 1 else 0 end  
    + 1* if self.randomized then 1 else 0 end 
    + 1* if self.controlled_against_placebo then 1 else 0 end 
    + 1* if self.controlled_against_best_alt then 1 else 0 end                
  end  
end
