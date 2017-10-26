class AddPaymentReceivableStatusToPaymentReceivable < ActiveRecord::Migration
  def change
    add_reference :payment_receivables, :payment_receivable_status, index: true, foreign_key: true
  end
end
