class MakeExpenseRelatedModelsSoftDeletable < ActiveRecord::Migration[4.2]
  def change
    add_column :card_expenses, :is_deleted, :boolean, default: false
    add_column :manual_expenses, :is_deleted, :boolean, default: false
    add_column :card_transactions, :is_deleted, :boolean, default: false
  end
end
