class CreateFindings < ActiveRecord::Migration
  def change
    create_table :findings do |t|
      t.text :finding
      t.integer :research_id

      t.timestamps
    end
    add_index :findings, [:created_at]        
  end
end
