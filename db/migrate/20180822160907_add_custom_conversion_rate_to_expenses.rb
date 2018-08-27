class AddCustomConversionRateToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :custom_conversion_rate, :boolean, default: false
  end
end
