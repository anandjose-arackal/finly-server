class AddModifiedByIdToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :modified_by_id, :integer
  end
end
