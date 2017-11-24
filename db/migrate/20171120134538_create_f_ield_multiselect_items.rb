class CreateFIeldMultiselectItems < ActiveRecord::Migration
  def change
    create_table :field_multiselect_items do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
