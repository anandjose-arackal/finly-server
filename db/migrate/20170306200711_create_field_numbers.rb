class CreateFieldNumbers < ActiveRecord::Migration[4.2]
  def change
    create_table :field_numbers do |t|
      t.text :value, null: false

      t.timestamps null: false
    end
  end
end
