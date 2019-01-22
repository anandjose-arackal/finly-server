class RemoveTypeIdColumnFromBeneficiries < ActiveRecord::Migration[4.2]
  def change
    remove_column :itz_cash_dmt_beneficiaries, :type_id
  end
end
