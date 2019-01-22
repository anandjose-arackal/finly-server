class AddCustomConversionRateToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :custom_conversion_rate, :boolean, default: false
  end
end
