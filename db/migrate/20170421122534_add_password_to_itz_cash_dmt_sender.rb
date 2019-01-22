class AddPasswordToItzCashDmtSender < ActiveRecord::Migration[4.2]
  def change
    add_column :itz_cash_dmt_senders, :password, :string
  end
end
