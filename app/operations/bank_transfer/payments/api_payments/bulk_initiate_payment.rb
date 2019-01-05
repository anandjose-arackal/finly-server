# this operation will initiate payments in sidekiq and then credit the entire payment order
# payment by payment because if there are too many the request will go on forever
class BankTransfer::Payments::ApiPayments::BulkInitiatePayment < BankTransfer::Payments::Base

  attr_accessor :payment_request_params, :errors, :payments_attributes, :errors_result,
                :total_amount_requested, :bank_payment_request, :company_id, :payment_mode

  class BankTransfer::Payments::ApiPayments::BulkInitiatePayment::BulkSuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_payment_request

    def init
      self.bank_payment_request = params[:bank_payment_request]
    end
  end

  class BankTransfer::Payments::ApiPayments::BulkInitiatePayment::BulkFailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :errors

    def init
      self.errors = params[:errors]
    end
  end


  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def init
    self.company_id = user.company_id
    self.payment_mode = params[:mode]
    self.payments_attributes = params[:payments]
    self.errors_result = []
    self.total_amount_requested = 0
  end

  def validate
    errors_found = false
    self.payments_attributes.each do |payment|
      payment[:errors] = []
      if payment[:account_number].blank?
        payment[:errors] << "Account number cannot be blank"
        errors_found = true
      end

      # check if this bank account exists and if it has been blacklisted
      ba = user.company.bank_accounts.find_by(account_number: payment[:account_number])
      if ba&.disabled?
        payment[:errors] << "This account has been blacklisted, you cannot make transfers to this account"
        errors_found = true
      end

      if payment[:ifsc].blank?
        payment[:errors] << "IFSC cannot be blank"
        errors_found = true
      end

      # todo - come back to this regex check
      # unless payment[:ifsc] =~ Constants::VALID_IFSC
      #   payment[:errors] << "IFSC cannot be blank"
      #   errors_found = true
      # end

      if payment[:amount].blank?
        payment[:errors] << "Amount cannot be blank"
        errors_found = true
      end

      if payment[:name].blank?
        payment[:errors] << "Name cannot be blank"
        errors_found = true
      end

      # if no errors are found add a message saying n errors found
      unless errors_found
        payment[:errors] << "No errors found"
      end

      self.total_amount_requested += payment[:amount].to_f
    end
    if errors_found
      self.errors_result = self.payments_attributes
      add_message :error, "Some of the payments have errors, please rectify them and retry"
    end
  end

  def process
    payment_order_attributes = {
        initiating_user_id: user.id,
        payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
        company_id: user.company_id,
        amount_requested_attributes: {
            value: self.total_amount_requested,
            currency_id: 1
        },
        payment_mode: self.payment_mode,
        initiating_account_type: YesBankCompanyAccount.name,
        receiving_account_type: BankAccount.name,
        payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
        application: "vp",
        currency_id: Currency.first.id,
        api_initiated: true
    }
    bpr_attributes = {
        owner_id: user.id,
        status_id: BankPaymentRequestStatus.id_for(:open),
        controlling_user_id: user.id,
        requested_amount_attributes: {
            value: self.total_amount_requested,
            currency_id: 1
        },
        beneficiary_type_id: 2,
        policy_id: user.company.policies.default.first.id,
        payment_order_attributes: payment_order_attributes,
        api_initiated: true
    }
    self.bank_payment_request = BankPaymentRequest.create(bpr_attributes)

    # now pass this bank payment request object as well as the payments attributes data to
    # the background operation so that they can be run asynchronously
    op = BankTransfer::Payments::ApiPayments::InitiatePaymentBackground.call_async(user, {bank_payment_request_id: self.bank_payment_request.id, payments_attributes: self.payments_attributes})
    # op = BankTransfer::Payments::ApiPayments::InitiatePaymentBackground.(user, {bank_payment_request: self.bank_payment_request, payments_attributes: self.payments_attributes})
  end

  def post_process
    add_message :success, "Payments have been successfully initiated, please check in some time for the payment statuses"
  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::Payments::ApiPayments::BulkInitiatePayment::BulkSuccessPresenter.new(user, params, messages)
  end

  def failure
    params[:errors] = self.errors_result
    BankTransfer::Payments::ApiPayments::BulkInitiatePayment::BulkFailurePresenter.new(user, params, messages)
  end

  private

  def create_beneficiary
    ba = BankAccount.non_deleted.find_by(account_number: params[:account_number]&.strip, ifsc: params[:ifsc]&.strip,
                                         name: params[:name]&.strip,
                                         company_id: self.company_id)
    self.vendor = ba&.account_owner || YesBankVendor.find_or_create_by(name: params[:name], company_id: self.company_id)
    ba&.update(is_deleted: false) # i.e. if the bank account already exists, mark it as non deleted
    if ba.nil?
      ba = BankAccount.create(name: params[:name], account_number: params[:account_number]&.strip, ifsc: params[:ifsc]&.strip,
                              account_owner: vendor, company_id: self.company_id, default_account: true)

    end
    self.bank_account = ba
  end

end