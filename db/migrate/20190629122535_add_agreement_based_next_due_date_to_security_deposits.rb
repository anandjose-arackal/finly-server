class AddAgreementBasedNextDueDateToSecurityDeposits < ActiveRecord::Migration[5.2]
  def change
    add_column :security_deposits, :agreement_based_next_due_date, :date
  end
end
