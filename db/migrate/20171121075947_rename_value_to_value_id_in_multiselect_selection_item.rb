class RenameValueToValueIdInMultiselectSelectionItem < ActiveRecord::Migration
  def change
    rename_column :field_multiselect_selection_items, :value, :value_id
  end
end
