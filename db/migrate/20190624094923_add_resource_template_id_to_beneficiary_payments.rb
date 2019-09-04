class AddResourceTemplateIdToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :resource_template_id, :integer
    add_index :beneficiary_payments, :resource_template_id
  end
end
