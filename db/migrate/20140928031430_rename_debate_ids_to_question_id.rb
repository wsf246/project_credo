class RenameDebateIdsToQuestionId < ActiveRecord::Migration
  def change
    change_table :points do |t|
      t.rename :debate_id, :question_id
    end 
    change_table :verdicts do |t|
      t.rename :debate_id, :question_id
    end 
  end
end
