class BankTransfer::PaymentRequest::RemoveAttachment < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_request, :attachment

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)
    attachment_id = params[:attachment_id]
    self.attachment = self.bank_payment_request.payment_order.payment_order_attachments.find_by(id: attachment_id)
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment order not found"
      return
    end

    if self.attachment.blank?
      add_message :error, "Attachment not found"
      return
    end
  end

  def process
    unless self.attachment.destroy
      add_message :error, self.attachment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Attachment removed!"
  end
end