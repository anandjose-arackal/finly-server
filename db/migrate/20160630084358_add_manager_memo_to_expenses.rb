class AddManagerMemoToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :manager_memo, :string
  end
end
