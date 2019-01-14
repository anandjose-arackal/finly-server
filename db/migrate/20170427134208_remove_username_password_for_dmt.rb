class RemoveUsernamePasswordForDmt < ActiveRecord::Migration[4.2]
  def change
    remove_column :itz_cash_dmt_senders, :username
    remove_column :itz_cash_dmt_senders, :password
  end
end
