class UpdateInternalMessageColumnToLargeText < ActiveRecord::Migration[6.0]
  def change
    change_column :import_records, :internal_message, :longtext
  end
end
