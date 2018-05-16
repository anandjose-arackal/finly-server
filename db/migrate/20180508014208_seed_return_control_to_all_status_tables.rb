class SeedReturnControlToAllStatusTables < ActiveRecord::Migration
  def change
    BankPaymentRequestCommentAction.seed_data
    BankPaymentRequestTrailAction.seed_data
  end
end
