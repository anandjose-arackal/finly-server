class ChangeAmountTypeInQuotations < ActiveRecord::Migration[5.2]
  def change
  	change_column :quotations, :total_amount, :decimal, precision: 20, scale: 2
  	change_column :quotations, :advance_amount, :decimal, precision: 20, scale: 2
  end
end
