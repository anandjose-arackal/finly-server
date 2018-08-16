class AddSpentFromIdToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :spent_from_id, :integer, references: "UserPocket", foreign_key: true, index: true
  end
end
