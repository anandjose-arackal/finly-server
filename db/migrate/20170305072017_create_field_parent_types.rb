class CreateFieldParentTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :field_parent_types do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
