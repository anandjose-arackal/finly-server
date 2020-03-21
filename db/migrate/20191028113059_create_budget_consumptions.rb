class CreateBudgetConsumptions < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_consumptions do |t|
      t.integer :pending_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :committed_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :pending_payment_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :payment_processing_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :paid_amount_id, references: "Amount", foreign_key: true, index: true
      t.integer :budget_id, references: "Budget", foreign_key: true, index: true
      t.datetime :deleted_at, index: true

      t.timestamps
    end
  end
end
