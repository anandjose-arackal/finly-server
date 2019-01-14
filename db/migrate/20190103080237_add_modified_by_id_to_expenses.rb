class AddModifiedByIdToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :modified_by_id, :integer
  end
end
