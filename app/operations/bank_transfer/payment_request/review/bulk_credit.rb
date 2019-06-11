class BankTransfer::PaymentRequest::Review::BulkCredit < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :result, :initiating_account_adapter, :payment_orders,
                :initiating_account, :creditable_payment_requests, :creditable_payment_orders,
                :view_role

  def pre_validate
    super
    return if has_errors?
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
    ids = params[:payment_request_ids] || params[:bank_payment_request_ids] || params[:ids]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    # op = BankTransfer::PaymentRequest::Index.(user, params)
    # if op.success?
    #   payment_request_ids = op.payment_requests.with_controlling_user(user.id).with_id(ids).pluck(:id)
    #   if user.vendor_payments_admin?
    #     payment_request_ids += op.payment_requests.creditable.with_id(ids).pluck(:id)
    #   end
    #   self.payment_requests = op.payment_requests.with_id(payment_request_ids)
    #   self.payment_orders = PaymentOrder.with_id(self.payment_requests.pluck(:payment_order_id))
    # else
    #   add_message :error, op.messages[:error]
    # end

    # NEW CODE
    op = BankTransfer::PaymentRequest::Index.(user, params)

    if op.success?
      self.payment_requests = op.payment_requests.creditable.with_id(ids)
      self.payment_orders = PaymentOrder.with_id(self.payment_requests.pluck(:payment_order_id))
    else
      add_message :error, op.messages[:error]
    end

    self.initiating_account = retrieve_initiating_account
    self.view_role = UserRole.id_for(params[:view].to_sym)
  end

  def validate
    if self.payment_requests.empty?
      add_message :error, "Payment orders not found"
      return
    end

    # check if there is enough balance in the source account for this transaction
    self.initiating_account_adapter = retrieve_initiating_account_adapter
    creditable_payment_orders = self.payment_requests.pluck(:payment_order_id)
    requested_amount = PaymentOrder.with_id(creditable_payment_orders).joins(:amount_requested).sum(:value)
    unless requested_amount <= self.initiating_account_adapter.balance
      add_message :error, "You do not have enough balance in the initiating account to initiate this transfer"
      # todo = should trigger a mailer or notification preferably
      return
    end

    #checking if the OTP for all the payment tickets are the same as the one passed in the request
    otp = self.payment_requests.pluck(:otp).uniq
    unless otp.size == 1
      add_message :error, "Invalid OTP, try again"
      return
    end

    unless otp.first == self.otp
      add_message :error, "Wrong OTP entered. Please enter the riht OTP and try again"
      return
    end
  end

  def pre_process
    # update the initiating account for all these payment orders as the one passed in the params
    self.payment_orders.update_all(initiating_account_type: self.initiating_account.class.name)
    payments = ::Payment.with_payment_order_id(self.payment_orders.pluck(:id))
    payments.update_all(initiating_account_id: self.initiating_account.id, initiating_account_type: self.initiating_account.class.name)

    # scheduling the payment orders that can be scheduled here, and excluding them from the
    # eventually processed payment orders
    schedulable_payment_request_ids = []
    self.payment_requests.each do |payment_request|
      allowed = TransferTimingUtils.within_timeframe?(payment_request.payment_order.payment_mode, nil)
      # now if the payment order is either scheduled or cannot be processed at this time, we mark it as to be scheduled
      unless allowed
        schedulable_payment_request_ids << payment_request.id
      end
    end
    schedulable_payment_requests = BankPaymentRequest.with_id(schedulable_payment_request_ids)
    schedulable_payment_requests.each do |payment_request|
      # retrieve the next kosher date for the transfer, and update the scheduled at date to that one
      next_date = TransferTimingUtils.next_valid_date(DateUtils.local_date_time, payment_request.payment_order.payment_mode)
      payment_request.payment_order.update(scheduled_at: next_date)
      payment_request.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:scheduled))
      #todo workflow manager can be introduced here; which will also create a trail for it
    end
    # self.creditable_payment_requests = self.payment_requests.without_id(schedulable_payment_request_ids)
    # self.creditable_payment_orders = ::PaymentOrder.with_id(self.creditable_payment_requests.pluck(:payment_order_id))
  end

  def process
    # iterate through all the payment orders and create a credited trail for all of them
    ids = []

    self.payment_requests.each do |payment_request|
      # update the bank_payment_request to credited
      # payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited), controlling_user: nil, controlling_user_role_id: nil,
      #                             controlling_for_user_id: nil, controlling_for_user_role_id: nil)
      # # create a trail to show that the BPR was credited
      # payment_request.bank_payment_request_trails.create action_user: user,
      #                                                    action_user_role_id: self.view_role,
      #                                                    action_id: BankPaymentRequestTrailAction.id_for(:credit),
      #                                                    modified_user_id: nil,
      #                                                    modified_user_role_id: nil
      # unless payment_request.payment_order.reload.scheduled?
      #   # accumulating the ids of all the payment orders that are to be processed right away
      #   ids << payment_request.id
      # end

      # New Code
      # NEW CODE
      params[:document] = payment_request
      params[:aasm_event] = 'credit'
      params[:violation_present] = false
      op_2 = WorkflowManager::Base.(user, params)

      if op_2.success?
        payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:credit)
      end
      #
      # self.workflow_output = op.workflow_output
      unless payment_request.payment_order.reload.scheduled?
        # accumulating the ids of all the payment orders that are to be processed right away
        ids << payment_request.id
      end
    end
    self.creditable_payment_requests = ::BankPaymentRequest.with_id(ids)
    self.creditable_payment_orders = ::PaymentOrder.with_id(self.creditable_payment_requests.pluck(:payment_order_id))
    # updating all the payment orders to pending state
    self.creditable_payment_orders.update_all(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
    # updating all the individual payments to pending state
    payments = ::Payment.with_payment_order_id(self.creditable_payment_orders.pluck(:id))
    payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
    BankTransfer::PaymentRequest::Review::CreditBackground.call_async(ids, initiating_user_id: user.id)
    # BankTransfer::PaymentRequest::Review::CreditBackground.call(ids, initiating_user_id: user.id) #todo make it async
  end

  def post_process
    add_message :success, "Payment Orders credit initiated"
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