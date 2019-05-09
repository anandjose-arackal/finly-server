class BankTransfer::PaymentRequest::Update::UpdateAttachment < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :attachment_params

  def pre_validate

  end

  def init
    super
    self.attachment_params = request_params
  end

  def pre_process
    self.attachment_params[:uploader_id] = user.id
    self.attachment_params.permit!
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
    params.require(:bank_payment_request).permit(:attached_file, :description, :allow_delete)
  end
end

