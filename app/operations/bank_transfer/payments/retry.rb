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

  end

  def process
    # simple call the retry operation in Account Manager and wait for the result
    op = AccountManager::Payments::RetryPayment.(self.payment)
    unless op.success?
      add_message :error, op.messages[:error]
    end
  end

  def post_process
    add_message :success, "Payment initiated! Check back in some time to check the status"
  end

end