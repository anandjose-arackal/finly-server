class CreateFieldDropDownSelections < ActiveRecord::Migration[4.2]
  def change
    create_table :field_drop_down_selections do |t|
      t.integer :value_id, null: false, references: 'FieldDropDownItem', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
