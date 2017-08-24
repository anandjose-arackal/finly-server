# this operation will update details like scheduled on, description, bank transfer type etc.
# about the payment order, which is independent of the payment items

class BankTransfer::PaymentRequest::Update::UpdateSummary < BankTransfer::PaymentRequest::Base

  attr_accessor :summary_params

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
    if params[:bank_transfer_request].blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    super
    self.summary_params = order_summary_params
  end

  def process
    unless payment_order.update(summary_params)
      add_message :error, payment_order.errors.full_messages
    end
  end

  def post_process
    add_message :error, "Successfully updated summary"
  end

  private

  def order_summary_params
    p = {}
    p = params.require(:bank_transfer_request).permit(:scheduled_at, :description)
    p[:payments_attributes] = []
    if params[:bank_transfer_request][:bank_transfer_type].present?
      payment_order.payments.each do |payment|
        p[:payments_attributes] << {
            id: payment.id,
            payment_mode: params[:bank_transfer_request][:bank_transfer_type]
        }
      end
    end
    p
  end
end