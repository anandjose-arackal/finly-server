class AddDateToCompanyBalanceHistories < ActiveRecord::Migration
  def change
    add_column :company_balance_histories, :date, :date
  end
end
