class RenameDiscountedAmountInInvoices < ActiveRecord::Migration
  def change
    rename_column :invoices, :discounted_amount_id, :discount_amount_id
  end
end
