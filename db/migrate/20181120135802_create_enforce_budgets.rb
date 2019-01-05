class CreateEnforceBudgets < ActiveRecord::Migration[4.2]
  def change
    create_table :enforce_budgets do |t|
      t.boolean :enforce_purchase_order_budget
      t.boolean :enforce_payment_budget
      t.boolean :enforce_expense_budget
      t.boolean :enforce_invoice_budget
      t.integer :company_id,  references: "Company", foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
