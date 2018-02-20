class BankTransfer::PaymentRequest::Review::BulkCredit < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :result, :initiating_account_adapter, :payment_orders,
                :initiating_account

  def init
    ids = params[:payment_request_ids] || params[:bank_payment_request_ids] || params[:ids]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      payment_request_ids = op.payment_requests.with_controlling_user(user.id).with_id(ids).pluck(:id)
      if user.vendor_payments_admin?
        payment_request_ids += op.payment_requests.creditable.with_id(ids).pluck(:id)
      end
      self.payment_requests = op.payment_requests.with_controlling_user(user.id).with_id(payment_request_ids)
      self.payment_orders = PaymentOrder.with_id(self.payment_requests.pluck(:payment_order_id))
    else
      add_message :error, op.messages[:error]
    end
    self.initiating_account = retrieve_initiating_account
  end

  def validate
    if self.payment_requests.empty?
      add_message :error, "Payment orders not found"
      return
    end

    # check if there is enough balance in the source account for this transaction
    self.initiating_account_adapter = retrieve_initiating_account_adapter
    approved_payment_orders = self.payment_requests.creditable.pluck(:payment_order_id)
    requested_amount = PaymentOrder.with_id(approved_payment_orders).joins(:amount_requested).sum(:value)
    unless requested_amount <= self.initiating_account_adapter.balance
      add_message :error, "You do not have enough balance in the initiating account to initiate this transfer"
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
      if !allowed || (payment_request.payment_order.scheduled_at.present? && payment_request.payment_order.scheduled_at >= DateUtils.local_date)
        schedulable_payment_request_ids << payment_request.id
      end
    end
    schedulable_payment_requests = BankPaymentRequest.with_id(schedulable_payment_request_ids)
    schedulable_payment_requests.each do |payment_request|
      # retrieve the next kosher date for the transfer, and update the scheduled at date to that one
      next_date = TransferTimingUtils.next_valid_date(DateUtils.local_date_time, payment_request.payment_order.payment_mode)
      payment_request.payment_order.update(scheduled_at: next_date)
    end
    self.payment_requests = self.payment_requests.without_id(schedulable_payment_request_ids)
  end

  def process
    # update the status of all payment orders as pending
    ids = self.payment_requests.pluck(:id)
    self.payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    # updating all the payment orders to pending state
    self.payment_orders.update_all(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
    # updating all the individual payments to pending state
    payments = ::Payment.with_payment_order_id(self.payment_orders.pluck(:id))
    payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
    BankTransfer::PaymentRequest::Review::CreditBackground.call_async(ids, initiating_user_id: user.id)
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