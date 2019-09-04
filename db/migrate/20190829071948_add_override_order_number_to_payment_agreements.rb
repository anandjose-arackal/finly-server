class AddOverrideOrderNumberToPaymentAgreements < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_agreements, :override_order_number, :string
  end
end
