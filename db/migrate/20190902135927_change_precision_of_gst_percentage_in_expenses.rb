class ChangePrecisionOfGstPercentageInExpenses < ActiveRecord::Migration[5.2]
  def change
    change_column :expenses, :gst_percentage, :decimal, precision: 10, scale: 5
    change_column :expenses, :tds_percentage, :decimal, precision: 10, scale: 5
  end
end
