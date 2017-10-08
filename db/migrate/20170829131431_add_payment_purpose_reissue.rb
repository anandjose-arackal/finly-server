class AddPaymentPurposeReissue < ActiveRecord::Migration
  def change
    # for seeding payment purpose "reissue"
    PaymentPurpose.seed_data
  end
end
