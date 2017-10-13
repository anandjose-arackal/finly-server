class AddOdometerReadingToDistanceExpense < ActiveRecord::Migration
  def up
    add_column :distance_expenses, :odometer_reading_start, :decimal
    add_column :distance_expenses, :odometer_reading_end, :decimal
    add_column :distance_expenses, :odometer_reading_receipt_start_id, :integer, index: true, foreign_key: true, references: 'Receipt'
    add_column :distance_expenses, :odometer_reading_receipt_end_id, :integer, index: true, foreign_key: true, references: 'Receipt'
  end
end
