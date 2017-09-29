class BankTransfer::PaymentRequest::Update::UpdatePayments < BankTransfer::PaymentRequest::Update::Base

  attr_accessor :order_params, :requested_total, :original_values

  def pre_validate
    super
    if params[:bank_payment_request][:payments_attributes].blank?
      add_message :error, "Missing payment details, try again"
      return
    end
  end

  def init
    super
    self.order_params = payment_order_params
    self.original_values = []
  end

  def validate
    # check if any of the amounts are zero and add appropriate error message
    params[:bank_payment_request][:payments_attributes].each do |account_details|
      if account_details[:amount].blank? || account_details[:amount]&.to_f <= 0
        add_message :error, "Amount cannot be less than or equal to zero"
      end
    end
  end

  def pre_process
    self.requested_total = 0
    params[:bank_payment_request][:payments_attributes].each do |details|
      self.requested_total += details[:amount]&.to_f
    end
    self.payment_order.payments.each do |payment|
      self.original_values << {
          name: payment.receiving_account.name,
          account_number: payment.receiving_account.account_number,
          ifsc: payment.receiving_account.ifsc,
          amount: payment.amount_value,
          id: payment.id
      }
    end
  end

  def process
    unless payment_order.update(order_params)
      add_message :error, payment_order.errors.full_messages
    end
    payment_order.amount_requested.update(value: requested_total)
  end

  def post_process
    # now peruse through each payment and find out what has changed where
    if payment_request.retracted? || payment_request.rejected?
      self.original_values.each do |old_payment_values|
        id = old_payment_values[:id]
        payment = payment_order.payments.find_by(id: id)
        if payment.amount_value.to_f != old_payment_values[:amount].to_f
          # add comment indicating the change in value
          self.payment_request.comments.build(action_id: BankPaymentRequestCommentAction.id_for(:payment_edit),
                                              previous_value: old_payment_values[:amount],
                                              new_value: payment.amount_value,
                                              beneficiary_id: payment.receiving_account.id,
                                              edited_field: "Amount",
                                              user_id: user.id).save
        end
      end
    end

    add_message :success, "Payment Details edited!"
  end

  private

  def payment_order_params
    parameters = {payments_attributes: []}
    p = params.require(:bank_payment_request).permit(payments_attributes: [:amount, :id, :note])

    p[:payments_attributes].each do |account_details|
      id = account_details[:id]
      payment = payment_order.payments.find_by(id: id)
      parameters[:payments_attributes] << {
          id: account_details[:id],
          note: account_details[:note],
          amount_attributes: {
              id: payment.amount.id,
              value: account_details[:amount]
        }
      }
    end
    parameters
  end
end
