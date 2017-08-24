class BankTransfer::PaymentRequest::Update::UpdateAttachment < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_request, :payment_order, :attachment_params

  def pre_validate

  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.payment_request = BankPaymentRequest.find_by(id: id)
    self.payment_order = payment_request.payment_order
    self.attachment_params = request_params
  end

  def process
    attachment = payment_order.payment_order_attachments.build(attachment_params)
    unless attachment.save
      add_message :error, attachment.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Attachment uploaded!"
  end

  private

  def request_params
    params.require(:bank_payment_request).permit(:attached_file, :description)
  end
end
