class AddPaymentPurposeReissue < ActiveRecord::Migration[4.2]
  def change
    # for seeding payment purpose "reissue"
    PaymentPurpose.seed_data
  end
end
