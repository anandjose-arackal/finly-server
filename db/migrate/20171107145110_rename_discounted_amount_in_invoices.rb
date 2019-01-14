class RenameDiscountedAmountInInvoices < ActiveRecord::Migration[4.2]
  def change
    rename_column :invoices, :discounted_amount_id, :discount_amount_id
  end
end
