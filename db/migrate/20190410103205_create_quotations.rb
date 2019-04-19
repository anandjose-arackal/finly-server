class CreateQuotations < ActiveRecord::Migration[5.2]
  def change
    create_table :quotations do |t|
      t.string :vendor_name
      t.string :vendor_location
      t.string :estimated_delivery_time
      t.string :total_amount
      t.string :advance_amount
      t.string :credit_period
      t.text :note
      t.boolean :selected

      t.timestamps
    end
  end
end
