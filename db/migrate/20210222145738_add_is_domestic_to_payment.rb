class AddIsDomesticToPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :bank_payment_requests, :is_domestic, :boolean, default: true
  end
end
