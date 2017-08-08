class MoveCurrentPaymentOrdersToDisburse < ActiveRecord::Migration
  def change
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
