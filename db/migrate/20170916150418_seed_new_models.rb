class SeedNewModels < ActiveRecord::Migration
  def change
    BankPaymentRequestCommentAction.seed_data

  end
end
