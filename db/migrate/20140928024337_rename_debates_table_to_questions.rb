class RenameDebatesTableToQuestions < ActiveRecord::Migration
  def change
    rename_table :debates, :questions
    change_table :questions do |t|
      t.rename :title, :question
    end  
    add_column :questions, :type, :text
  end
end
