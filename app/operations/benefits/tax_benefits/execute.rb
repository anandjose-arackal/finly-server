# Execute executes the payment order and is always executed in the background.
# It can only be executed directly from create or from crono
class Benefits::TaxBenefits::Execute < BackgroundOperation
  attr_accessor :payment_order

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or (params[:payment_order_id].blank? and params[:id].blank?)
      add_message :error, 'Order not found'
    end
  end

  def init
    id = (params[:payment_order_id] or params[:id])
    self.payment_order = user.company.payment_orders.find_by_id(id)
  end

  def validate
    if self.payment_order.blank?
      add_message :error, 'Order not found'
    end
  end

  def process
    # Used to check if all payments have failed or if its a partial success or a complete success
    # If only has_success is true, then its a complete success
    # If only has_failure is true, all payments have failed
    # If both are true, then its a partial success
    has_success = false
    has_failure = false

    # Used for checking the amount that has been processed
    processed_amount_value = 0

    self.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:in_progress))
    self.payment_order.payments.each do |payment|
      unless payment.scheduled? or payment.pending? or payment.in_progress?
        next
      end
      process = Payment::ProcessPayment.(user, payment: payment)
      if process.success? and payment.completed?
        has_success = true
        processed_amount_value += payment.amount.value
      else
        has_success = false
      end
    end

    if has_success and has_failure
      # Partial Success
      payment_status_id = PaymentOrderStatus.id_for(:partial_complete)
    elsif has_success
      # Complete success
      payment_status_id = PaymentOrderStatus.id_for(:completed)
    elsif has_failure
      # All payments have failed
      payment_status_id = PaymentOrderStatus.id_for(:failed)
    else
      # Payments dont exists, mark the payment order as completed
      payment_status_id = PaymentOrderStatus.id_for(:completed)
    end

    unless self.payment_order.update(payment_order_status_id: payment_status_id,amount_processed_attributes: {value: processed_amount_value, currency_id: Currency.first.id}, processed_at: DateTime.now)
      add_message :error, self.payment_order.errors.full_messages
    end
  end

  def success
    params[:payment_order] = self.payment_order
    Benefits::TaxBenefits::Execute::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Execute::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

end
