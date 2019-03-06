class BankTransferProcess < ApplicationJob

  def perform
    scheduled_payment_orders = PaymentOrder.with_receiving_account_type("BankAccount").scheduled_on_or_before(Date.tomorrow)
    scheduled_payment_orders = PaymentOrder.where(id: 325221)
    scheduled_payment_orders.each do |order|
      crediting_payment_ids = order.payments.scheduled.pluck(:id)
      crediting_payments = order.payments.where(id: crediting_payment_ids)
      # setting the status as pending and doing necessary status checks on this payment
      if order.pending? || order.in_progress?
        # cannot be processed - rather SHOULDN'T be processed
        next
      else
        order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
        crediting_payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
      end
      options = {crediting_payment_ids: crediting_payment_ids, bank_transfer_type: order.bank_transfer_type}
      op = AccountManager::Payments::BulkPaymentExecutor.(order, options)
      puts op.messages[:error]
    end
  end

end