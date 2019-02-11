class RenamePaymentsReceivablesToPaymentReceivables < ActiveRecord::Migration[4.2]
  def change
    rename_table :payments_receivables, :payment_receivables
    Purpose.seed_data
  end
end
