class AddDeletedAtToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
  	PaymentAgreement.migrate_to_paranoid
  	SecurityDeposit.migrate_to_paranoid
  end
end
