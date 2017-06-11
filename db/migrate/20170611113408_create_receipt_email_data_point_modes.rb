class CreateReceiptEmailDataPointModes < ActiveRecord::Migration
  def change
    create_table :receipt_email_data_point_modes do |t|
      t.string :name, null:false

      t.timestamps null: false
    end
    ReceiptEmailDataPointMode.seed_data
  end
end
