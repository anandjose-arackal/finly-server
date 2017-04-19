# Create is used to create the required payment order and prepare for execution.
# If the order is scheduled, it schedules the payment_order,
# or else it calls the Benefits::TaxBenefits::Execute in background to execute the payment order
class Benefits::TaxBenefits::Create < Benefits::TaxBenefits::Base
  attr_accessor :order_data, :processed_order_data, :payment_order, :scheduled_at

  def pre_validate
    super
    return if has_errors?
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:payment_order].blank?
      add_message :error, 'Error loading request'
      return
    end
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate the transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
    end
  end

  def init
    self.order_data = params[:payment_order]
    self.processed_order_data = Benefits::TaxBenefits::Process.(config, user, payment_order: self.order_data, card_program_id: card_program_id)
    self.scheduled_at = self.processed_order_data.scheduled_at
  end

  def validate

    if scheduled_at && scheduled_at < Date.today
      add_message :error, 'Scheduled Date cannot be less than the current date'
      return
    end

    if self.processed_order_data.blank?
      add_message :error, 'Error loading configuration. Please try again'
      return
    end

    if self.processed_order_data.failure?
      add_message :error, self.processed_order_data.messages[:error]
      return
    end

    unless self.processed_order_data.payment_order_valid
      add_message :error, 'Please fix the issues before confirming the request'
    end

  end

  def process

    if scheduled_at.present?
      payment_order_status_id = PaymentOrderStatus.id_for(:scheduled)
    else
      payment_order_status_id = PaymentOrderStatus.id_for(:pending)
    end

    amount_requested = Amount.new(value: self.processed_order_data.requested_amount, currency_id: 1)

    debugger

    payment_order_params = { payment_order_type_id: payment_order_type_id,
        scheduled_at: self.scheduled_at,
        processed_at: DateTime.now,
        initiating_user: user,
        payment_order_status_id: payment_order_status_id,
        company_id: user.company_id,
        amount_requested: amount_requested }

    self.payment_order = user.payment_orders.build payment_order_params

    unless self.payment_order.valid?
      add_message :error, self.payment_order.errors.full_messages
      return
    end

    initiating_user = user
    initiating_user_account = user.company
    date = Date.today
    if scheduled_at.present? and scheduled_at > Date.today
      payment_status_id = PaymentStatus.id_for(:scheduled)
    else
      payment_status_id = PaymentStatus.id_for(:pending)
    end

    self.processed_order_data.processed_order.each do |item|
      receiving_user = item[:user][:user_details]
      receiving_account = item[:card]
      amount = item[:amount]

      payment_order.payments.build amount_attributes: {value: amount, currency_id: 1},
                                   date: date, payment_type_id: payment_type_id,
                                   initiating_user: initiating_user, receiving_user: receiving_user,
                                   initiating_account: initiating_user_account,
                                   receiving_account: receiving_account,
                                   payment_status_id: payment_status_id
    end

    if self.payment_order.save
      unless scheduled_at.present?
        Benefits::TaxBenefits::Execute.call_async(user.id, payment_order_id: self.payment_order.id)
      end
    else
      add_message :error, self.payment_order.errors.full_messages
      self.payment_order.destroy
    end
  end

  def success
    params[:payment_order] = self.payment_order
    Benefits::TaxBenefits::Create::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

end
