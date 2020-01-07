class SeedPaymentRetryToBankPaymentRequestCommentActions < ActiveRecord::Migration[5.2]
  def change
  	BankPaymentRequestCommentAction.seed_data
  end
end
