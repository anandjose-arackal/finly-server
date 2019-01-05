class CreateFieldDropDownItems < ActiveRecord::Migration[4.2]
  def change
    create_table :field_drop_down_items do |t|
      t.string :name, null: false
      t.references :field_configuration, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
