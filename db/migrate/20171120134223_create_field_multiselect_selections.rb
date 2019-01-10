class CreateFieldMultiselectSelections < ActiveRecord::Migration[4.2]
  def change
    FieldType.seed_data
    create_table :field_multiselect_selections do |t|

      t.timestamps null: false
    end
  end
end
