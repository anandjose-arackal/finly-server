class EditSizeOfTextAttributeCrono < ActiveRecord::Migration
  def change
    change_column :crono_jobs, :log, :text, :limit => 16.megabytes - 1
  end
end
