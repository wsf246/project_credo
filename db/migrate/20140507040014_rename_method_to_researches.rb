class RenameMethodToResearches < ActiveRecord::Migration
  def change
  	change_table :researches do |t|
      t.rename :type, :study_type
      t.remove :methods
    end  
  end
end
