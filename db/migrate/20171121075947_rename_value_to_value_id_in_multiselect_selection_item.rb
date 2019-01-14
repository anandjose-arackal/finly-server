class RenameValueToValueIdInMultiselectSelectionItem < ActiveRecord::Migration[4.2]
  def change
    rename_column :field_multiselect_selection_items, :value, :value_id
  end
end
