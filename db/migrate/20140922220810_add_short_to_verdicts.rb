class AddShortToVerdicts < ActiveRecord::Migration
  def change
    add_column :verdicts, :short, :text
  end
end
