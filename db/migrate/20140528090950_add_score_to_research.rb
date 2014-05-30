class AddScoreToResearch < ActiveRecord::Migration
  def change
    add_column :researches, :score, :float    
  end
end
