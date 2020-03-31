class AddPoAndInvoiceDetailsToBudgetTrail < ActiveRecord::Migration[5.2]
  def change
    # add_column :budget_trails, :purchase_order_id, :integer, references: "PurchaseOrder", foreign_key: true, index: true
    # add_column :budget_trails, :invoice_id, :integer, references: "Invoice", foreign_key: true, index: true
    # add_column :budget_trails, :payment_purpose_id, :integer, references: "PaymentPurpose", foreign_key: true, index: true
  end
end
