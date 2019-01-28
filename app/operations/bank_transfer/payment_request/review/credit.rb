# Once approved, this operation will take the payment order and perform a credit for
# the payments that are passed int he request
# the initiating account can be changed at this stage as well

class BankTransfer::PaymentRequest::Review::Credit < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :initiating_account, :initiating_account_adapter, :view_role,
                :crediting_payments, :bank_transfer_type

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
    self.crediting_payments = self.bank_payment_request.payments.creditable.with_id(payment_ids) # this ensures only failed or pending approval payments can be processed
    self.bank_transfer_type = self.bank_payment_request&.payment_order&.bank_transfer_type
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment order not found"
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
  end

  def pre_process
    # updating the initiating account for the payments
    # payment_order.update(initiating_account_type: initiating_account.class.name) # this probably doesn't make sense here because each individual payment now can be initiated from anywhere
    self.crediting_payments.update_all(initiating_account_id: initiating_account.id, initiating_account_type: initiating_account.class.name)

    # check if the payment order can be executed at this moment, otherwise schedule it for the next working day
    unless TransferTimingUtils.within_timeframe?(payment_order&.payment_mode, payment_order&.scheduled_at)
      # retrieve the next kosher date for the transfer, and update the scheduled at date to that one
      next_date = TransferTimingUtils.next_valid_date(DateUtils.local_date_time, payment_order.payment_mode)
      self.crediting_payments.update_all(scheduled_at: next_date)
    end

  end


  def process
    # now pass these payments to the PaymentProcessor operation so that it can process the credit for all of them
    # op = BankTransfer::YesBank::Create.(user, bank_payment_request: bank_payment_request)
    op = AccountManager::Payments::PaymentProcessor.(user, {crediting_payments: self.crediting_payments, bank_transfer_type: self.bank_transfer_type,
                                                            background: true, payment_order: self.payment_order})
    if op.success?
      # update the bank_payment_request to credited
      # bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited), controlling_user: nil, controlling_user_role_id: nil,
      #                             controlling_for_user_id: nil, controlling_for_user_role_id: nil)
      # # create a trail to show that the BPR was credited
      # bank_payment_request.bank_payment_request_trails.create action_user: user,
      #                                                         action_user_role_id: self.view_role,
      #                                                         action_id: BankPaymentRequestTrailAction.id_for(:credit),
      #                                                         modified_user_id: nil,
      #                                                         modified_user_role_id: nil

      # NEW CODE
      params[:document] = self.payment_request
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
      bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:failed))
      return
    end
  end

  def post_process
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:credit)

    role_id: self.workflow_output[:role_id]                                     
    Event::EBankPaymentRequest::Credit.(user, bank_payment_request: bank_payment_request, role_id: role_id)


    add_message :success, "Payment Order credit initiated!"
  end

  private

  def retrieve_initiating_account
    case params[:initiating_account_type]
      when 1, '1'
        return user.company.yes_bank_company_account
      when 2, '2'
        return user.bank_wallet
      else
        user.bank_wallet # i.e. finly money by default
    end
  end

  def retrieve_initiating_account_adapter
    case params[:initiating_account_type]
      when 1, '1'
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
      when 2, '2'
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
      else
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
    end
  end

end