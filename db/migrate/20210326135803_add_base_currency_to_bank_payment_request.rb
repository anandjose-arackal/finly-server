class AddBaseCurrencyToBankPaymentRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_payment_requests, :base_currency_id, :integer
  end
end
