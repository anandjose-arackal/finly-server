class EncodeFormCustomField < ActiveRecord::Migration[6.0]
  def change
    change_column :form_custom_fields, :value, "TEXT(255) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
