class ChangeBeneficiaryPaymentsName < ActiveRecord::Migration[6.0]
  def change
    change_column :beneficiary_payments, :name, "VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
