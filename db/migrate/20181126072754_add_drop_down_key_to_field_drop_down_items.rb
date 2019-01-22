class AddDropDownKeyToFieldDropDownItems < ActiveRecord::Migration[4.2]
  def change
    add_column :field_drop_down_items, :field_key, :string
  end
end