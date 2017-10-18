class RenamePaymentsReceivablesToPaymentReceivables < ActiveRecord::Migration
  def change
    rename_table :payments_receivables, :payment_receivables
  end
end
