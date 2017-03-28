class ModifyTimeAndDistanceExpenses < ActiveRecord::Migration
  def change
    remove_column :distance_expenses, :distance, :decimal
    remove_column :distance_expenses, :unit, :string
    remove_column :time_expenses, :units, :string
    remove_column :time_expenses, :duration, :decimal

    add_column :distance_expenses, :distance_id, :integer, references: "Distance", foreign_key: true, index: true
    add_column :time_expenses, :time_object_id, :integer, references: "TimeObject", foreign_key: true, index: true
  end
end
