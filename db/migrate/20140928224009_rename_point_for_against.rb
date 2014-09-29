class RenamePointForAgainst < ActiveRecord::Migration
  def change
    remove_column :points, :for_against
    add_column :points, :point_type, :text
  end
end
