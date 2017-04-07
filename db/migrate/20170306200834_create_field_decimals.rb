class CreateFieldDecimals < ActiveRecord::Migration
  def change
    create_table :field_decimals do |t|
      t.text :value, null: false

      t.timestamps null: false
    end
  end
end
