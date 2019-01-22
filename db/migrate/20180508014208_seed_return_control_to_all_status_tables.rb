class SeedReturnControlToAllStatusTables < ActiveRecord::Migration[4.2]
  def change
    BankPaymentRequestCommentAction.seed_data
    BankPaymentRequestTrailAction.seed_data
  end
end
