class Journal < ActiveRecord::Base
  def peer_review_format
    if self.peer_reviewed == "Y"
      "#{self.name} (PR)"
    else
      "#{self.name} (Unk)"
    end    
  end
end
