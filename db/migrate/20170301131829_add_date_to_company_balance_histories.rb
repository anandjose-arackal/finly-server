class AddDateToCompanyBalanceHistories < ActiveRecord::Migration[4.2]
  def change
    add_column :company_balance_histories, :date, :date
  end
end
