class AddDeletedToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :is_deleted, :boolean, default: false, null: false
    add_column :reports, :is_deleted, :boolean, default: false, null: false
    add_column :policies, :is_deleted, :boolean, default: false, null: false
    add_column :money_requests, :is_deleted, :boolean, default: false, null: false
  end
end