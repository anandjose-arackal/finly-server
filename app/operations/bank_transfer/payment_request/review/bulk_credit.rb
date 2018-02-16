class BankTransfer::PaymentRequest::Review::BulkCredit < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :result, :initiating_account_adapter, :payment_orders,
                :initiating_account

  def init
    ids = params[:payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.payment_requests = op.payment_requests.creditable.with_id(ids)
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
    approved_payment_orders = self.bank_payment_requests.creditable.pluck(:payment_order_id)
    requested_amount = PaymentOrder.with_id(approved_payment_orders).joins(:amount_requested).sum(:value)
    unless requested_amount <= self.initiating_account_adapter.balance
      add_message :error, "You do not have enough balance in the initiating account to initiate this transfer"
      return
    end
  end

  def pre_process
    # update the initiating account for all these payment orders as the one passed in the params
    self.payment_orders.update_all(initiating_account: self.initiating_account)
    payments = Payment.with_payment_order_id(self.payment_orders.pluck(:id))
    payments.update_all(initiating_account: self.initiating_account)

    # scheduling the payment orders that can be scheduled here, and excluding them from the
    # eventually processed payment orders
    schedulable_payment_order_ids = []
    self.payment_requests.each do |payment_request|
      allowed = TransferTimingUtils.within_timeframe?(payment_request.payment_order.payment_mode, nil)
      unless allowed
        schedulable_payment_order_ids << payment_request.id
      end
    end
    self.payment_requests = self.payment_requests.without_id(schedulable_payment_order_ids)
  end

  def process
    # update the status of all payment orders as pending
    self.payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    ids = self.bank_payment_requests.pluck(:id)
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