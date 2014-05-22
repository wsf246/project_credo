class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.text :point
      t.boolean :for_against
      t.integer :debate_id
      t.integer :finding_id

      t.timestamps
    end
  end
end
