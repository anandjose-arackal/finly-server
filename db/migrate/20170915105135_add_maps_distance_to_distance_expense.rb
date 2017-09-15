class AddMapsDistanceToDistanceExpense < ActiveRecord::Migration
  def change
    add_column :distance_expenses, :maps_distance_id, :integer, references: 'Distance', index: true, foreign_key: true
  end
end
