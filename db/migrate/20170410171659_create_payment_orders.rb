class CreatePaymentOrders < ActiveRecord::Migration
  def change
    create_table :payment_orders do |t|
      # t.references :payment_order_type, index: true, foreign_key: true, null: false
      t.date :scheduled_at
      t.datetime :processed_at
      t.integer :initiating_user_id, null: false, index: true, foreign_key: true, references: 'User'
      t.references :payment_order_status, index: true, foreign_key: true, null: false
      t.attachment :payment_file
      t.references :company, index: true, foreign_key: true, null: false
      t.integer :amount_requested_id, null: false, index: true, foreign_key: true, references: 'Amount'
      t.integer :amount_processed_id, null: false, index: true, foreign_key: true, references: 'Amount'
      t.text :note

      t.timestamps null: false
    end

    add_column :payments, :payment_order_id, :integer,references: 'PaymentOrder', index: true, foreign_key: true
  end
end
