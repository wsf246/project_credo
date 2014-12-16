class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|
      t.text :source_type
      t.text :issn
      t.text :name
      t.text :publisher
      t.text :peer_reviewed

      t.timestamps
    end
  end
end
