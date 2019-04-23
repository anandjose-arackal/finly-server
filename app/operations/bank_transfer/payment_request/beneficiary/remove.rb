class BankTransfer::PaymentRequest::Beneficiary::Remove < BankTransfer::PaymentRequest::Beneficiary::Base

  attr_accessor :removed_payment, :beneficiary_account, :parent_details

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

    # case self.removed_payment.parent_type
    # when 'Invoice'
    #   self.parent_details = user.company.inward_invoices.non_beneficiary.find_by(id: self.removed_payment.parent_id)
    #   self.parent_details.update(invoice_status_id: InwardInvoiceStatus.id_for(:unpaid))
    # when 'PurchaseOrder'
    #   self.parent_details = user.company.purchase_orders.find_by(id: self.removed_payment.parent_id)
    #   self.parent_details.update(advance_amount_status_id: AdvanceAmountStatus.id_for(:to_be_processed))
    # end

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