class AddPaymentOrderAndProurementAssociationsToPayment < ActiveRecord::Migration
  def change
    add_reference :payments, :purchase_order, foreign_key: true
    add_reference :payments, :procurement, foreign_key: true
  end
end