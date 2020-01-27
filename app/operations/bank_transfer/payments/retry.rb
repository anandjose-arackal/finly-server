# this operation will retry an individual payment that has failed for any reason
# the retry is instant - as in, even scheduled payments will be retried instantly

class BankTransfer::Payments::Retry < BankTransfer::Payments::Base

  attr_accessor :payment, :payment_order, :payment_mode, :bank_payment_request

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    id = params[:id] || params[:payment_id]
    self.payment = Payment.where(company_id: user.company.id).find_by(id: id)
    self.payment_mode = params[:payment_mode] || self.payment&.payment_mode
    self.bank_payment_request = payment&.payment_order&.bank_payment_request
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

    bt = self.payment.reference_resource
    if bt.present? && !(bt&.retriable?)
      add_message :error, "Only failed payments can be retried"
      return
    end

    unless payment.payment_order.present?
      add_message :error, "This payment does not belong to a payment order"
      return
    end

    unless bank_payment_request.is_initiating_user?(user) || bank_payment_request.is_reviewing_user?(user) || bank_payment_request.is_crediting_user?(user)
      add_message :error, "You are not authorized to do this action"
      return
    end

    # ensuring that only invoices that are payable can have retriable payments
    if payment.parent_type == "Invoice"
      invoice = payment.parent
      unless invoice.payable
        add_message :error, "This payment cannot be processed as the sum total of payments against this invoice exceeds the invoice amount"
        return
      end
    end
  end

  def pre_process
    # update the payment mode for this payment alone
    if self.payment_mode.present?
      self.payment.update(payment_mode: self.payment_mode)
    end
  end

  def process
    # simple call the retry operation in Account Manager and wait for the result
    op = AccountManager::Payments::RetryPaymentBackground.call_async(self.payment.id, params)
  end

  def post_process
    self.payment.payment_order.bank_payment_request.comments.create user_id: user.id,
                                     action_id: BankPaymentRequestCommentAction.id_for(:payment_retry),
                                     note: "Retry for Payment ID - #{self.payment.id}"

    add_message :success, "Payment initiated! Check back in some time to check the status"
  end

end