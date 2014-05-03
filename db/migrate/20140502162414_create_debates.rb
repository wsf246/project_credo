class CreateDebates < ActiveRecord::Migration
  def change
    create_table :debates do |t|
      t.string :title
      t.text :description
      t.text :notes
      t.text :verdict

      t.timestamps
    end
    add_index :debates, [:created_at]
  end
end
