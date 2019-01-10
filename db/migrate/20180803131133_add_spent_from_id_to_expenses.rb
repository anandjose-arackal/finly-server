class AddSpentFromIdToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :spent_from_id, :integer, references: "UserPocket", foreign_key: true, index: true
  end
end
