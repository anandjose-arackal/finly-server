# when the data reaches this state, all payments will be valid and passing the respective
# basic presence validations
class BankTransfer::YesBank::Create < BankTransfer::YesBank::Base
  attr_accessor :order_data, :payment_request, :payment_order, :scheduled_at,
                :processed_order_data, :initiating_account

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
    # below variable will contain the payment_request that holds data about initiating accounts and
    # receiving accounts
    self.initiating_account = user.company.yes_bank_company_account
    op = BankTransfer::YesBank::Process.(user, scheduled_at: params[:scheduled_at],
        payment_order: self.order_data)
    self.processed_order_data = op.payment_order_data

    self.scheduled_at = op.scheduled_at
    self.payment_request = build_payment_request(processed_order_data)
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

    unless self.payment_request.valid?
      add_message :error, 'Please fix the issues before confirming the request'
    end
  end

  def process

    # calling the payment processor to complete the transfer using adapters
    op = AccountManager::Payments::PaymentProcessor.(initiating_user, {payment_request: payment_request})
    unless op.success?
      # destroy the payment order that was created for this purpose, and return errors
      add_message :error, op.messages[:error]
    end
    self.payment_order = op.payment_order
  end

  def success
    params[:payment_order] = self.payment_order
    BankTransfer::YesBank::Create::SuccessPresenter.new(user, params, messages)
  end

  class BankTransfer::YesBank::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

end

