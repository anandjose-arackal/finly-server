class SeedNewModels < ActiveRecord::Migration[4.2]
  def change
    BankPaymentRequestCommentAction.seed_data

  end
end
