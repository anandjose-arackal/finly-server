class RemoveTypeIdColumnFromBeneficiries < ActiveRecord::Migration
  def change
    remove_column :itz_cash_dmt_beneficiaries, :type_id
  end
end
