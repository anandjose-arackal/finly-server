class ModifyDistanceExpenseTable < ActiveRecord::Migration
  def change
    remove_column :distance_expenses, :time_object_id
  end
end
