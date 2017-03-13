class ModifyTimeAndDistanceExpenses < ActiveRecord::Migration
  def change
    remove_column :distance_expenses, :distance
    remove_column :distance_expenses, :unit
    remove_column :time_expenses, :units
    remove_column :time_expenses, :duration

    add_column :distance_expenses, :distance_id, :integer, references: "Distance", foreign_key: true, index: true
    add_column :distance_expenses, :time_object_id, :integer, references: "TimeObject", foreign_key: true, index: true
  end
end
