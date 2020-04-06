# Once approved, this operation will take the payment order and perform a credit for
# the payments that are passed int he request
# the initiating account can be changed at this stage as well

class BankTransfer::PaymentRequest::Review::Credit < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :initiating_account, :initiating_account_adapter, :view_role,
                :crediting_payments, :bank_transfer_type, :otp

  def personalizer
    {
        validate: {
            before: Personalizer::Process.new([:bank_payment_requests, :credit], :validate, self)
        }
    }
  end

  def pre_validate
    super
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
    super
    self.initiating_account = retrieve_initiating_account
    self.initiating_account_adapter = retrieve_initiating_account_adapter
    self.view_role = UserRole.id_for(params[:view].to_sym)
    payment_ids = params[:payment_ids]
    unless payment_ids.is_a?(Array)
      payment_ids = payment_ids&.split(",")
    end
    # self.crediting_payments = self.bank_payment_request.payments.creditable.with_id(payment_ids) # this ensures only failed or pending approval payments can be processed
    self.crediting_payments = self.bank_payment_request.payments.creditable # all payments will be done together
    self.bank_transfer_type = self.bank_payment_request&.payment_order&.bank_transfer_type
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment order not found"
      return
    end

    # checking for the right OTP for this particular bank payment request
    #todo - have to move this to the Payment Processor Rules branch
    self.otp = params[:otp]
    unless self.otp == self.bank_payment_request.otp
      add_message :error, "Invalid OTP. Please enter the right OTP and try again"
      return
    end

    # check whether the respective account has enough balance for this transaction
    requested_amount = self.crediting_payments.joins_amount.sum(:value)
    if requested_amount > initiating_account_adapter.balance(payment_process: true)
      add_message :error, "You do not have enough money in your account for this transaction"
      return
    end

    if self.crediting_payments.empty?
      add_message :error, "You need to choose at least once payment to process this order"
      return
    end

    if self.user.vendor_payments_creditor? && !self.user.vendor_payments_admin?
      minimum = self.bank_payment_request.policy.policy_user_roles.with_user_id(self.user).with_role_id(UserRole.id_for(:bank_payment_request_creditor)).first.min_amount
      maximum = self.bank_payment_request.policy.policy_user_roles.with_user_id(self.user).with_role_id(UserRole.id_for(:bank_payment_request_creditor)).first.max_amount || 999999999999999999999999

      max_payment_value = self.bank_payment_request.payments.joins(:amount).pluck(:value).max || 0
      if max_payment_value > maximum
        add_message :error, "You are not eligible to credit the payment order, you are eligible to credit only upto #{maximum}"
      elsif max_payment_value < minimum
        add_message :error, "You are not eligible to credit the payment order, you are eligible to credit only greater than #{minimum}"
      end
    end

    # All Payments inside a payment ticket should have homogeneous initiating account type
    payment_status_ids = [
        PaymentStatus.id_for(:completed),
        PaymentStatus.id_for(:failed),
        PaymentStatus.id_for(:pending),
        PaymentStatus.id_for(:in_progress),
        PaymentStatus.id_for(:scheduled),
        PaymentStatus.id_for(:cancelled),
        PaymentStatus.id_for(:processing),
        PaymentStatus.id_for(:possible_failure),
        PaymentStatus.id_for(:pending_credit),
        PaymentStatus.id_for(:pending_retry),
        PaymentStatus.id_for(:initiated),
    ]
    initiating_account_types = self.bank_payment_request.payments.where(payment_status_id: payment_status_ids).pluck(:initiating_account_type).uniq

    if initiating_account_types.length == 1
      initiating_account_type = initiating_account_types.first

      if initiating_account_type.present?
        case initiating_account_type
        when 'VendorPaymentWallet'
          unless [1, '1'].include?(params[:initiating_account_type]) || params[:initiating_account_type].blank?
            add_message :error, "You can only select 'Finly Money' for processing this payment ticket"
          end
        when 'YesBankCompanyAccount'
          unless [2, '2'].include?(params[:initiating_account_type]) && (params[:initiating_company_account_type].blank? || initiating_account_type == params[:initiating_company_account_type])
            add_message :error, "You can only select Yes Bank Company Account for processing this payment ticket"
          end
        when 'IciciBankCompanyAccount'
          unless params[:initiating_company_account_type].present? && initiating_account_type == params[:initiating_company_account_type]
            add_message :error, "You can only select Icici Bank Company Account for processing this payment ticket"
          end
        when 'KotakBankCompanyAccount'
          unless params[:initiating_company_account_type].present? && initiating_account_type == params[:initiating_company_account_type]
            add_message :error, "You can only select Kotak Bank Company Account for processing this payment ticket"
          end
        end
      end
    else
      Event::EAlert::Create.(nil, {
          title: 'BPR Payments have multiple initiating accounts',
          description: "The BPR w/ ID: #{self.bank_payment_request.id} has payments with multiple initiating accounts",
          subject: 'BPR Payments have multiple initiating accounts'
      })
    end

    case self.bank_payment_request.payments.first&.class&.name
    when 'Invoice'
      payments = self.bank_payment_request.payments.joins(:invoice).where(invoices: {invoice_status_id: InwardInvoiceStatus.id_for(:voided)})
      if payments.present?
        add_message :error, "Payments with IDs #{payments.pluck(:id).join(", ")} have invoices which are voided. Please remove them before marking the Ticket as credited."
        return
      end
    end
  end

  def pre_process
    # Updating all payments with newly selected imitating account
    self.bank_payment_request.payments.update_all(initiating_account_id: initiating_account.id, initiating_account_type: initiating_account.class.name)
    self.bank_payment_request.payment_order.update_columns(initiating_account_type: initiating_account.class.name)
    # updating the initiating account for the payments
    # payment_order.update(initiating_account_type: initiating_account.class.name) # this probably doesn't make sense here because each individual payment now can be initiated from anywhere
    self.crediting_payments.update_all(initiating_account_id: initiating_account.id, initiating_account_type: initiating_account.class.name)

    # check if the payment order can be executed at this moment, otherwise schedule it for the next working day
    unless TransferTimingUtils.within_timeframe?(payment_order&.payment_mode, payment_order&.scheduled_at)
      # retrieve the next kosher date for the transfer, and update the scheduled at date to that one
      next_date = TransferTimingUtils.next_valid_date(DateUtils.local_date_time, payment_order.payment_mode)
      self.crediting_payments.update_all(scheduled_at: next_date)
      self.payment_order.update(scheduled_at: next_date)
    end
    # if the payment order has been scheduled for tomorrow, update the payments' scheduled_at to reflect the same
    if self.payment_order&.scheduled_at.present? && self.payment_order&.scheduled_at > DateUtils.local_date
      # in this case also the payments need to be scheduled for the next day:
      self.crediting_payments.update_all(scheduled_at: self.payment_order&.scheduled_at)
    end
  end


  def process
    # now pass these payments to the PaymentProcessor operation so that it can process the credit for all of them
    # op = BankTransfer::YesBank::Create.(user, bank_payment_request: bank_payment_request)
    op = AccountManager::Payments::PaymentProcessor.(user, {crediting_payments: self.crediting_payments, bank_transfer_type: self.bank_transfer_type,
                                                            background: true, payment_order: self.payment_order})
    if op.success?

      # NEW CODE
      params[:document] = self.bank_payment_request
      params[:aasm_event] = 'credit'
      params[:violation_present] = false
      op = WorkflowManager::Base.(user, params)

      unless op.success?
        add_message :error, op.messages[:error]
        return
      end

      self.workflow_output = op.workflow_output

    else
      add_message :error, op.messages[:error]
      bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited))
      return
    end
  end

  def post_process
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:credit)

    role_id = self.workflow_output[:role_id]                                     
    Event::EBankPaymentRequest::Credit.(user, bank_payment_request: bank_payment_request, role_id: role_id)

    # Sending email to original document initiators about payments against it
    payments = self.bank_payment_request.payments
    payments.each do |payment|
      # notify vendor that they got the money they deserved
      Event::EBankPaymentRequest::NotifyVendor.(user, payment: payment)

      case payment.parent_type
      when 'Invoice'        
        document_owner = payment.invoice.created_by
        Event::EInvoice::Credit.(document_owner, {payment: payment})
      when 'PurchaseOrder'
        document_owner = payment.purchase_order.user
        Rails.logger.fatal "User from mark_as_credited #{document_owner.inspect}" 
        Event::EPurchaseOrder::Credit.(document_owner, {payment: payment})
      when 'Beneficiary'
        document_owner = payment.invoice.created_by
        Event::EBankPaymentRequest::Credit.(document_owner, {payment: payment})
      else
        document_owner = user
        Event::EBankPaymentRequest::Credit.(document_owner, {payment: payment})
      end
    end

    add_message :success, "Payment Order credit initiated!"
  end

  private

  def retrieve_initiating_account
    case params[:initiating_account_type]
    when 1, '1' # Company Credits
      # Currently assuming all companies will have only one account in each of the banks
      if params[:initiating_company_account_type].present?
        case params[:initiating_company_account_type]
        when "IciciBankCompanyAccount"
          user.company.icici_bank_company_account
        when "KotakBankCompanyAccount"
          user.company.kotak_bank_company_account
        when "YesBankCompanyAccount"
          return user.company.yes_bank_company_account
        when "UtilityBillsAccount"
          return user.company.utility_bills_account
        else
          return user.company.yes_bank_company_account
        end
      else
        case user.company&.feature_subscription&.bank_service_provider
        when "YES"
          return user.company.yes_bank_company_account
        when "ICICI"
          return user.company.icici_bank_company_account
        when "KOTAK"
          return user.company.kotak_bank_company_account
        else
          return user.company.yes_bank_company_account
        end
      end
    when 2, '2' # Finly Money
      return user.bank_wallet
    else
      user.bank_wallet # i.e. finly money by default
    end
  end

  def retrieve_initiating_account_adapter
    case params[:initiating_account_type]
    when 1, '1'
      # Currently assuming all companies will have only one account in each of the banks
      if params[:initiating_company_account_type].present?
        case params[:initiating_company_account_type]
        when "IciciBankCompanyAccount"
          return AccountManager::IciciBankAccount::IciciBankCompanyAccountAdapter.new(user.company.icici_bank_company_account)
        when "KotakBankCompanyAccount"
          return AccountManager::KotakBankAccount::KotakBankCompanyAccountAdapter.new(user.company.kotak_bank_company_account)
        when "YesBankCompanyAccount"
          return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
        when "UtilityBillsAccount"
          return AccountManager::BillingAccount::UtilityBillsAccountAdapter.new(user.company.utility_bills_account)
        else
          return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
        end
      else
        case user.company&.feature_subscription&.bank_service_provider
        when "YES"
          return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
        when "ICICI"
          return AccountManager::IciciBankAccount::IciciBankCompanyAccountAdapter.new(user.company.icici_bank_company_account)
        when "KOTAK"
          return AccountManager::KotakBankAccount::KotakBankCompanyAccountAdapter.new(user.company.kotak_bank_company_account)
        else
          return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
        end
      end
    when 2, '2'
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
      else
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
    end
  end

end