class AddDefaultToItzCashDmtBeneficiaries < ActiveRecord::Migration
  def change
    add_column :itz_cash_dmt_beneficiaries, :default, :boolean
  end
end
