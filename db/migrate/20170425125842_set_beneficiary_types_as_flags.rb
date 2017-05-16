class SetBeneficiaryTypesAsFlags < ActiveRecord::Migration
  def change
    # drop_table :itz_cash_dmt_beneficiary_types
    add_column :itz_cash_dmt_beneficiaries, :reimbursement, :boolean, index: true, default: false
  end
end
