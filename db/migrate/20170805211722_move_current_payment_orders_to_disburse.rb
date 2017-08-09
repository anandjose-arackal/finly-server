class MoveCurrentPaymentOrdersToDisburse < ActiveRecord::Migration
  def change
<<<<<<< HEAD
=======
    # add_column :payment_orders, :application, :string
>>>>>>> origin/staging-hotfixes
    PaymentOrder.all.each do |po|
      po.update(application: :ft)
      po.payments.update_all(application: :ft)
    end
    Payment.all.each do |payment|
      if payment.application.nil?
        payment.update(application: :em)
      end
    end
  end
end
