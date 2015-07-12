class ChangeAssociationRelations < ActiveRecord::Migration
  def change
    change_table :associations do |t|
      t.rename :point_id, :question_id
      t.rename :finding_id, :research_id
    end 
  end
end
