class AddDefaultToItzCashDmtBeneficiaries < ActiveRecord::Migration[4.2]
  def change
    add_column :itz_cash_dmt_beneficiaries, :default, :boolean
  end
end
