class AddPasswordToItzCashDmtSender < ActiveRecord::Migration
  def change
    add_column :itz_cash_dmt_senders, :password, :string
  end
end
