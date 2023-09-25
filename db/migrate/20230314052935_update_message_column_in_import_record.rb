class UpdateMessageColumnInImportRecord < ActiveRecord::Migration[6.0]
  def change
    change_column :import_records, :message, "VARCHAR(511) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
