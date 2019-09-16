class AddAgreementIdToSecurityDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :security_deposits, :payment_agreement_id, :integer
  end
end
