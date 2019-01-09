class BankTransferProcess < ActiveJob::Base

  def perform
    scheduled_payment_orders = PaymentOrder.with_receiving_account_type("BankAccount").scheduled_on_or_before(Date.tomorrow)
    scheduled_payment_orders.each do |order|
      BankTransfer::YesBank::Execute.call(order.initiating_user, payment_order_id: order.id)
    end
  end

end