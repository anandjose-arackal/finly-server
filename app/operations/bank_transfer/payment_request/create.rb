# when the data reaches this state, all payments will be valid and passing the respective
# basic presence validations
class BankTransfer::PaymentRequest::Create < BankTransfer::PaymentRequest::Base
  attr_accessor :order_data, :payment_request, :payment_order, :scheduled_at,
                :processed_order_data, :initiating_account, :order_params

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
      return
    end
  end

  def init
    self.order_data = params[:payment_order]
    op = BankTransfer::PaymentRequest::Process.(user, scheduled_at: params[:scheduled_at],
        payment_order: self.order_data)
    self.processed_order_data = op.payment_order_data

    # setting the initiating account based on the type of user creating the
    # request as well as the option chosen by the admin
    self.initiating_account = retrieve_initiating_account
    ##########################################################

    #### setting the bank transfer type from the front end ####
    params[:bank_transfer_type] = params[:transfer_type].upcase
    ###########################################################

    self.scheduled_at = op.scheduled_at
    # below variable will contain the payment_request that holds data about initiating accounts and
    # receiving accounts
    self.order_params = payment_order_params
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

  end

  def process
    # this should now create a BankPaymentRequest and save it in the SB
  end

  def post_process
    add_message :success, "Transfers scheduled successfully!"
  end

  def success
    params[:payment_order] = self.payment_order
    BankTransfer::PaymentRequest::Create::SuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:payment_order] = self.payment_order
    BankTransfer::PaymentRequest::Create::FailurePresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Create::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

  class BankTransfer::YesBank::Create::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :payment_order

    def init
      self.payment_order = params[:payment_order]
    end

  end

  private

  def payment_order_params
    payment_order_data.each do |key, value|

    end
  end

end

