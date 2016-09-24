class AddDeletedToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :is_deleted, :boolean, default: false, null: false
    add_column :reports, :is_deleted, :boolean, default: false, null: false
  end
end