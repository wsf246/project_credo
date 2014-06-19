class AddCachedVotesToPoints < ActiveRecord::Migration
  def change
    add_column :points, :cached_votes_total, :integer, :default => 0
    add_index  :points, :cached_votes_total    
  end
end
