# will retry a single payment synchronously when requested

class AccountManager::Payments::RetryPayment < AccountManager::Base

  attr_accessor :payment

  def initialize(payment)
    self.payment = payment
  end

  def validate
    unless payment.failed?
      add_message :error, "Only failed payments can be retried"
      return
    end

    unless payment.payment_order.present?
      add_message :error, "This payment does not belong to a payment order"
      return
    end
  end

  def pre_process
    # changing the status of the payment as pending
    payment.update(payment_status_id: PaymentStatus.id_for(:pending))
  end

  def process
    # calling payment executor so that the payment can be successfully executed using the respective adapters
    op = AccountManager::Payments::PaymentExecutor.(self.payment)
    if op.success?
      if self.payment_order.payments.pluck(:payment_status_id).uniq == [PaymentStatus.id_for(:completed)]
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
      elsif self.payment_order.payments.pluck(:payment_status_id).uniq == [PaymentStatus.id_for(:failed)]
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:failed))
      else
        # this is partially completed
        self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:partially_completed))
      end
    else
      # no change in the payment order or payment anyway. So do nothing?
    end
  end

  def post_process
    add_message :success, "Payment retry successfully executed"
  end
  
end