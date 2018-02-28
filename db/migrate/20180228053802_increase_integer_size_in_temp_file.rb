class IncreaseIntegerSizeInTempFile < ActiveRecord::Migration
  def change
    change_column :temporary_files, :file_file_size, :integer, limit: 8
  end
end
