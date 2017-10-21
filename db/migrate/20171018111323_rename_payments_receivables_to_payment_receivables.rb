class RenamePaymentsReceivablesToPaymentReceivables < ActiveRecord::Migration
  def change
    rename_table :payments_receivables, :payment_receivables
    MappingPurpose.seed_data
  end
end
