class BankTransfer::PaymentRequest::Beneficiary::Remove < BankTransfer::PaymentRequest::Beneficiary::Base

  attr_accessor :removed_payment, :beneficiary_account

  def init
    super
    id = params[:payment_id]
    self.removed_payment = payment_order&.payments.find_by(id: id)
  end

  def pre_process
    self.beneficiary_account = self.removed_payment.receiving_account
  end

  def process
    unless self.removed_payment.destroy
      add_message :error, self.removed_payment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment successfully removed"

    # update the amount requested for this particular payment order
    amount_requested = self.payment_order.request_total
    payment_order.amount_requested.update(value: amount_requested)

    # add a comment for this removal
    if bank_payment_request.retracted? || bank_payment_request.rejected?
      # adding comments for all the beneficiaries added and removed in the comments
      self.bank_payment_request.comments.build(action_id: BankPaymentRequestCommentAction.id_for(:remove_beneficiary),
                                               user_id: user.id,
                                                beneficiary_id: self.beneficiary_account.id).save
    end
  end
end