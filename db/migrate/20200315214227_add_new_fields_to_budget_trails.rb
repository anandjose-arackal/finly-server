class AddNewFieldsToBudgetTrails < ActiveRecord::Migration[5.2]
  def change
    # add_column :budget_trails, :payment_processing_amount_before_tax_value, :decimal, precision: 20, scale: 10, default: 0
    # add_column :budget_trails, :payment_processing_amount_after_tax_value, :decimal, precision: 20, scale: 10, default: 0
    # add_column :budget_trails, :tds_value, :decimal, precision: 20, scale: 10, default: 0
    # add_column :budget_trails, :billed, :boolean, default: false
    # add_column :budget_trails, :entity_status_id, :integer, index: true
    # add_column :budget_trails, :reimbursable, :boolean, default: false, index: true
    # add_column :budget_trails, :amount_before_tax_id, :integer, references: "Amount", foreign_key: true, index: true
    # add_column :budget_trails, :amount_after_tax_id, :integer, references: "Amount", foreign_key: true, index: true
    # add_column :budget_trails, :entity_created_at, :datetime, index: true
    # add_column :budget_trails, :entity_submitted_at, :datetime, index: true
    # add_column :budget_trails, :purchase_order_id, :integer, references: "PurchaseOrder", foreign_key: true, index: true
    # add_column :budget_trails, :invoice_id, :integer, references: "Invoice", foreign_key: true, index: true
    # add_column :budget_trails, :payment_purpose_id, :integer, references: "PaymentPurpose", foreign_key: true, index: true
    # add_column :budget_trails, :po_trail_item_id, :integer, references: "BudgetTrail", foreign_key: true, index: true
    # add_column :budget_trails, :billed_amount_before_tax_value, :decimal, precision: 20, scale: 10
    # add_column :budget_trails, :billed_amount_after_tax_value, :decimal, precision: 20, scale: 10
    # add_column :budget_trails, :remaining_amount_before_tax_value, :decimal, precision: 20, scale: 10
    # add_column :budget_trails, :remaining_amount_after_tax_value, :decimal, precision: 20, scale: 10
    # add_column :budget_trails, :paid_amount_before_tax_value, :decimal, precision: 20, scale: 10, default: 0
    # add_column :budget_trails, :paid_amount_after_tax_value, :decimal, precision: 20, scale: 10, default: 0
  end
end
