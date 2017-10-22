class MakeDropdownItemSoftdeletable < ActiveRecord::Migration
  def change
    add_column :field_drop_down_items, :is_deleted, :boolean, index: true, default: false
  end
end
