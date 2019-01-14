class AddVoucherExpenseDateToTallyConfiguration < ActiveRecord::Migration[4.2]
  def change
    add_column :tally_configurations, :voucher_expense_date, :string
  end
end
