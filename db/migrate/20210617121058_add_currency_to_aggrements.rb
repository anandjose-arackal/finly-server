class AddCurrencyToAggrements < ActiveRecord::Migration[6.0]
  def change

    add_column :security_deposits, :base_currency_id, :integer
    add_column :security_deposits, :reporting_currency_id, :integer
    
    add_column :beneficiary_payments, :base_currency_id, :integer
    add_column :beneficiary_payments, :reporting_currency_id, :integer
  
  end
end
