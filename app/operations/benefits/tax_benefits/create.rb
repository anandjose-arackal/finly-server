# this operation would now create the payment request from the payment order data being passed in the controller
# and pass it to the payment processor
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
    self.processed_order_data = Benefits::TaxBenefits::Process.(config, user, scheduled_at: params[:scheduled_at],
        payment_order: self.order_data, card_program_id: card_program_id)
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

    initiating_user = user
    # todo update this to dynamically pick an initiating_account
    initiating_account = user.company.itz_cash_company_account

    payment_request = PaymentRequest.(initiating_user, initiating_account, Card.name, :credit, :corporate_balance_load, {scheduled_at: self.scheduled_at, background: true})
    self.processed_order_data.processed_order.each do |item|

      receiving_user = item[:user][:user_details]
      receiving_account = item[:card]
      amount = item[:amount]

      payment_request.add_payment_item(PaymentRequest::PaymentItem.(receiving_user, receiving_account, amount))
    end
    # calling the payment processor to complete the transfer using adapters
    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
    unless op.success?
      # destroy the payment order that was created for this purpose, and return errors
      add_message :error, op.messages[:error]
      return
    end
    self.payment_order = op.payment_order
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
