class AddVoucherExpenseDateToTallyConfiguration < ActiveRecord::Migration
  def change
    add_column :tally_configurations, :voucher_expense_date, :string
  end
end
