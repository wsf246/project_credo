class AddCachedUpDownVotes < ActiveRecord::Migration
  def change
    add_column :questions, :cached_votes_up, :integer, :default => 0
    add_index  :questions, :cached_votes_up
    add_column :questions, :cached_votes_down, :integer, :default => 0
    add_index  :questions, :cached_votes_down
    add_column :points, :cached_votes_up, :integer, :default => 0
    add_index  :points, :cached_votes_up
    add_column :points, :cached_votes_down, :integer, :default => 0
    add_index  :points, :cached_votes_down
    add_column :verdicts, :cached_votes_up, :integer, :default => 0
    add_index  :verdicts, :cached_votes_up
    add_column :verdicts, :cached_votes_down, :integer, :default => 0
    add_index  :verdicts, :cached_votes_down                       
  end
end
