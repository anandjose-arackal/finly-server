class CreateFieldBooleans < ActiveRecord::Migration
  def change
    create_table :field_booleans do |t|
      t.boolean :value, null: false

      t.timestamps null: false
    end
  end
end
