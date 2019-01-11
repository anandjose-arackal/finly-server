class AddOdometerReadingToDistanceExpense < ActiveRecord::Migration[4.2]
  def change
    add_column :distance_expenses, :odometer_reading_start, :decimal, precision: 10, scale: 2
    add_column :distance_expenses, :odometer_reading_end, :decimal, precision: 10, scale: 2
    add_column :distance_expenses, :odometer_reading_receipt_start_id, :integer, index: true, foreign_key: true, references: 'Receipt'
    add_column :distance_expenses, :odometer_reading_receipt_end_id, :integer, index: true, foreign_key: true, references: 'Receipt'
  end
end
