class AddMapsDistanceToDistanceExpense < ActiveRecord::Migration
  def change
    add_column :distance_expenses, :maps_distance, :float
  end
end
