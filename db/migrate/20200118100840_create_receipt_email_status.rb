class CreateReceiptEmailStatus < ActiveRecord::Migration[5.2]
  def change
    create_table :receipt_email_statuses do |t|
      t.string :name, index: true, null: false
      t.timestamps
    end
  end
end
