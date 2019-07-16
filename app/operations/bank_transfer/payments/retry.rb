# this operation will retry an individual payment that has failed for any reason
# the retry is instant - as in, even scheduled payments will be retried instantly

class BankTransfer::Payments::Retry < BankTransfer::Payments::Base

  attr_accessor :payment, :payment_order

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:payment_id]
    op = BankTransfer::Payments::Index.(user, params)
    self.payment = op.payments.find_by(id: id)
  end

  def validate
    if self.payment.blank?
      add_message :error, "Payment not found"
      return
    end

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
    # update the payment mode for this payment alone
    self.payment.update(payment_mode: params[:payment_mode])
  end

  def process
    # simple call the retry operation in Account Manager and wait for the result
    op = AccountManager::Payments::RetryPaymentBackground.call_async(self.payment.id, params)
  end

  def post_process
    add_message :success, "Payment initiated! Check back in some time to check the status"
  end

end