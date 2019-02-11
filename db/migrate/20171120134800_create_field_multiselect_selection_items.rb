class CreateFieldMultiselectSelectionItems < ActiveRecord::Migration[4.2]
  def change
    create_table :field_multiselect_selection_items do |t|
      t.integer :value, references: "FIeldMultiSelectItem", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
