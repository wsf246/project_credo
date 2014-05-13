class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.text :quote
      t.integer :research_id

      t.timestamps
    end
    add_index :quotes, [:created_at]    
  end
end
