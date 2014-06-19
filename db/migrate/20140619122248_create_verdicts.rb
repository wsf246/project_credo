class CreateVerdicts < ActiveRecord::Migration
  def change
    create_table :verdicts do |t|
      t.text :verdict
      t.integer :debate_id
      t.integer :cached_votes_total, :default => 0
    
      t.timestamps
    end
    change_table :debates do |t|
      t.remove :verdict
    end      
  add_index  :verdicts, :cached_votes_total  
  end
end
