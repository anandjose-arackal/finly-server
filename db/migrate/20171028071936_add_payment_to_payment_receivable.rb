class AddPaymentToPaymentReceivable < ActiveRecord::Migration
  def change
    add_column :payment_receivables, :payment_id, :integer, references: "Payment", foreign_key: true, index: true
  end
end
