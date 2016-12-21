class AddManagerMemoToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :manager_memo, :text
    add_column :expenses, :rejecting_manager_id, :integer, :references => "user", index: true, foreign_key: true
  end
end
