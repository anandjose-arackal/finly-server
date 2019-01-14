class MakeMultiselectItemsSoftdeletable < ActiveRecord::Migration[4.2]
  def change
    add_column :field_multiselect_items, :is_deleted, :boolean
  end
end
