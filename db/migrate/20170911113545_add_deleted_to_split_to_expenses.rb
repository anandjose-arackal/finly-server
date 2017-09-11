class AddDeletedToSplitToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :deleted_to_split, :boolean, default: false
  end
end
