class AddSampleDefToFindings < ActiveRecord::Migration
  def change
  	add_column :findings, :sample_def, :text
  	add_column :findings, :quote, :text  	
  end
  drop_table :sample_defs
  drop_table :quotes
end
