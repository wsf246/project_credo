class CreateSampleDefs < ActiveRecord::Migration
  def change
    create_table :sample_defs do |t|
      t.text :sample_def
      t.integer :research_id

      t.timestamps
    end
    add_index :sample_defs, [:created_at]        
  end
end
