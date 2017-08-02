# this operation creates the respective payment order and associated payment items from the excel sheet for processing
# by the payment processor
class Benefits::TaxBenefits::Create < Benefits::TaxBenefits::Base
  attr_accessor :order_data, :payment_request, :payment_order, :scheduled_at

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
    self.payment_request = BankTransfer::YesBank::Process.(user, scheduled_at: params[:scheduled_at],
        payment_order: self.order_data, card_program_id: card_program_id)
    self.scheduled_at = self.processed_order_data.scheduled_at
  end

  def validate

    if scheduled_at && scheduled_at < Date.today
      add_message :error, 'Scheduled Date cannot be less than the current date'
      return
    end

    if self.payment_request.blank?
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
    Benefits::TaxBenefits::Create::SuccessPresenter.new(user, params, messages)
  end

  class Benefits::TaxBenefits::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

end
