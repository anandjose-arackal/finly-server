class EditSizeOfTextAttributeCrono < ActiveRecord::Migration[4.2]
  def change
    change_column :crono_jobs, :log, :text, :limit => 16.megabytes - 1
  end
end
