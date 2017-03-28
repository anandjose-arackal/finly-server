class CreateFieldAmounts < ActiveRecord::Migration
  def change
    create_table :field_amounts do |t|
      t.integer :value_id, null: false, references: 'Amount', index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
