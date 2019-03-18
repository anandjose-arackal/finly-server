class ChanfePaymentReferenceResourceToYesBankTransactions < ActiveRecord::Migration[5.2]
  def change
    Payment.where(reference_resource_type: "BankTransaction").update_all(reference_resource_type: "YesBankTransaction")
  end
end