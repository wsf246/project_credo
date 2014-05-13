class CreateResearches < ActiveRecord::Migration
  def change
    create_table :researches do |t|
      t.string :type
      t.string :methods
      t.string :authors
      t.text :title
      t.string :journal
      t.date :date_of_publication
      t.text :drouputs
      t.boolean :retraction
      t.boolean :peer_review
      t.boolean :reproduced
      t.string :version
      t.text :funding
      t.float :funding_bias
      t.string :link

      t.timestamps
    end
  end
end
