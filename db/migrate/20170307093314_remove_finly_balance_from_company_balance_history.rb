class RemoveFinlyBalanceFromCompanyBalanceHistory < ActiveRecord::Migration[4.2]
  def change
    remove_column :company_balance_histories, :finly_money_balance_id
  end
end
