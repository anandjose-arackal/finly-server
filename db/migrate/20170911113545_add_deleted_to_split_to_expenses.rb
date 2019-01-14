class AddDeletedToSplitToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :deleted_to_split, :boolean, default: false
  end
end
