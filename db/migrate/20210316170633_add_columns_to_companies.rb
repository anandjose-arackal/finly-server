class AddColumnsToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :reporting_currency_code, :string, default: 'INR'
  end
end
