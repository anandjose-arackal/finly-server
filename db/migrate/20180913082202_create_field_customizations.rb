class CreateFieldCustomizations < ActiveRecord::Migration[4.2]
  def change
    create_table :field_customizations do |t|
      t.string :class_name, index: true, null: false
      t.string :field_name, index: true, null: false
      t.boolean :enabled, index: true, null: false, default: false
      t.boolean :presence, index: true, null: false, default: false
      t.boolean :show_in_pdf, index: true, null: false, default: false
      t.references :scopable, index: true, null: false, polymorphic: true

      t.timestamps null: false
    end
  end
end
