class ChangeNameInLocations < ActiveRecord::Migration[5.2]
  def change
    change_column :locations, :name, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin"
    change_column :locations, :address, "TEXT(65535) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
