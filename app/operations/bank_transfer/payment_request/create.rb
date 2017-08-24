# when the data reaches this state, all payments will be valid and passing the respective
# basic presence validations
class BankTransfer::PaymentRequest::Create < BankTransfer::PaymentRequest::Base
  attr_accessor :order_data, :payment_request, :payment_order, :scheduled_at,
                :processed_order_data, :initiating_account, :request_params,
                :company_id, :bank_payment_request

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
    self.company_id = user.company_id
    # below variable will contain the payment_request that holds data about initiating accounts and
    # receiving accounts
    self.request_params = payment_request_params
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
    # this should now create a BankPaymentRequest and save it in the DB
    self.bank_payment_request = BankPaymentRequest.new(request_params)
    unless bank_payment_request.save
      add_message :error, bank_payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment Request created successfully!"
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

  def payment_request_params
    p = {}
    p[:owner_id] = user.id
    p[:status_id] = BankPaymentRequestStatus.id_for(:open)
    p[:controlling_user_id] = user.id
    # todo - need to ask Abi to provide this info in the request
    p[:requested_amount_attributes] = {
        value: params[:requested_amount],
        currency_id: Currency.first.id
    }
    p[:name] = "#{user.name}'s payment request"
    p[:payment_order_attributes] = {}
    p[:payment_order_attributes][:initiating_user] = user
    p[:payment_order_attributes][:payment_order_status_id] = PaymentOrderStatus.id_for(:pending_approval)
    p[:payment_order_attributes][:company_id] = self.company_id
    p[:payment_order_attributes][:amount_requested_attributes] = {
        value: params[:requested_amount],
        currency_id: Currency.first.id
    }
    p[:payment_order_attributes][:initiating_account_type] = initiating_account.class.name
    p[:payment_order_attributes][:receiving_account_type] = BankAccount.name
    p[:payment_order_attributes][:payment_purpose_id] = PaymentPurpose.id_for(:vendor_payment)
    p[:payment_order_attributes][:payments_attributes] = []
    p[:payment_order_attributes][:appplication] = RequestStore.store[:current_app]
    p[:payment_order_attributes][:description] = params[:description]
    payment_order_data.each do |order_details|
      bank_account = retrieve_bank_account order_details
      p[:payment_order_attributes][:payments_attributes] << {
          payment_type_id: PaymentType.id_for(:credit),
          application: RequestStore.store[:current_app],
          receiving_user_type: bank_account.account_owner.class.name,
          receiving_user_id: bank_account.account_owner_id,
          initiating_user_type: "User",
          initiating_user_id: user.id,
          initiating_account_type: "User",
          initiating_account_id: initiating_account.id,
          receiving_account_type: "BankAccount",
          receiving_account_id: bank_account.id,
          payment_status_id: PaymentStatus.id_for(:pending_approval),
          payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
          payment_mode: params[:bank_transfer_type],
          amount_attributes: {
              value: order_details[:amount],
              currency_id: Currency.first.id
          },
          date: DateUtils.local_date,
      }
    end
  end

  def retrieve_bank_account(order_details)
    ba = BankAccount.find_by(account_number: order_details[:bank_account_number],
                             company_id: self.company_id)
    vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: order_details[:name], company_id: self.company_id)

    if ba.nil?
      ba = BankAccount.create(name: order_details[:name], account_number: order_details[:bank_account_number], ifsc: ifsc, account_owner: vendor, company_id: self.company_id)
    end
    return ba
  end

end

