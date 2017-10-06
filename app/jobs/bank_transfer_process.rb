class BankTransferProcess < ActiveJob::Base

  def perform
    scheduled_payment_orders = PaymentOrder.from_vendor_payments.scheduled_on_or_before(Date.tomorrow)
    scheduled_payment_orders.each do |order|
      BankTransfer::YesBank::Execute.call(order.initiating_user, payment_order_id: order.id)
    end
  end

end