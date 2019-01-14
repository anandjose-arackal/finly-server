class IncreaseIntegerSizeInTempFile < ActiveRecord::Migration[4.2]
  def change
    change_column :temporary_files, :file_file_size, :integer, limit: 8
  end
end
