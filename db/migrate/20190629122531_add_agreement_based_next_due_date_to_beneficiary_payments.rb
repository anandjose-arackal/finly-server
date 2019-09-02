class AddAgreementBasedNextDueDateToBeneficiaryPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :beneficiary_payments, :agreement_based_next_due_date, :date
  end
end
