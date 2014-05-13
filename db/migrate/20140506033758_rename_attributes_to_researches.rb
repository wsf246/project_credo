class RenameAttributesToResearches < ActiveRecord::Migration
  def change
  	change_table :researches do |t|
      t.rename :drouputs, :dropouts
      t.rename  :retraction, :retracted
      t.rename  :peer_review, :peer_reviewed
      t.rename  :reproduced, :replicated
      t.boolean :single_blinded
      t.boolean :double_blinded
      t.boolean :randomized
      t.boolean :controlled_against_placebo
      t.boolean :controlled_against_best_alt
      t.remove :methodsS
    end  
  end
end
