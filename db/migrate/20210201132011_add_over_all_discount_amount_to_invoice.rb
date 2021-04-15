class AddOverAllDiscountAmountToInvoice < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :overall_discount_amount, :decimal, default: 0
  end
end
