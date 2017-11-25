class CreateFieldMultiselectSelections < ActiveRecord::Migration
  def change
    FieldType.seed_data
    create_table :field_multiselect_selections do |t|

      t.timestamps null: false
    end
  end
end
