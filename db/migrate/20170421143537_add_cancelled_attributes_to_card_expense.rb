class AddCancelledAttributesToCardExpense < ActiveRecord::Migration
  def change
    add_column :card_expenses, :cancelled, :boolean, default: false
    add_column :card_expenses, :cancelled_against_transaction, :integer, references: "CardTransaction", foreign_key: true, index: true
  end
end
