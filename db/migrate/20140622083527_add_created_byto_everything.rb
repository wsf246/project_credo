class AddCreatedBytoEverything < ActiveRecord::Migration
  def change
    add_column :points, :user_create_id, :integer
    add_column :debates, :user_create_id, :integer
    add_column :verdicts, :user_create_id, :integer
    add_column :researches, :user_create_id, :integer
    add_column :users, :username, :string   
  end
end
