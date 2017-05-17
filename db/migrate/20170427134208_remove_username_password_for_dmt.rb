class RemoveUsernamePasswordForDmt < ActiveRecord::Migration
  def change
    remove_column :itz_cash_dmt_senders, :username
    remove_column :itz_cash_dmt_senders, :password
  end
end
