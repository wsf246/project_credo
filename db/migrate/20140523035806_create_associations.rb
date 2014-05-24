class CreateAssociations < ActiveRecord::Migration
  def change
    create_table :associations do |t|
      t.integer :point_id
      t.integer :finding_id

      t.timestamps
    end
  end
end
