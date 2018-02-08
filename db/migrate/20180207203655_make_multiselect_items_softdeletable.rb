class MakeMultiselectItemsSoftdeletable < ActiveRecord::Migration
  def change
    add_column :field_multiselect_items, :is_deleted, :boolean
  end
end
