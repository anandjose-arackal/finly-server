class AddPaymentOrderAndProurementAssociationsToPayment < ActiveRecord::Migration[4.2]
  def change
    add_reference :payments, :purchase_order, foreign_key: true
    add_reference :payments, :procurement, foreign_key: true
  end
end