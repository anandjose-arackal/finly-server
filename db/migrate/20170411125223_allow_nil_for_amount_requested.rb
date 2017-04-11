class AllowNilForAmountRequested < ActiveRecord::Migration
  def change
    change_column :payment_orders, :amount_requested_id, :integer, :references => 'Amount', null: true, index: true, foreign_key: true
    change_column :payment_orders, :amount_processed_id, :integer, :references => 'Amount', null: true, index: true, foreign_key: true
  end
end
