# Once approved, this operation will take the payment order and perform a credit for it
# the initiating account can be changed at this stage as well

class BankTransfer::PaymentRequest::Review::Credit < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :initiating_account, :initiating_account_adapter

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
  end

  def validate
    # check whether the respective account has enough balance for this transaction
    requested_amount = payment_order.amount_requested.value
    if requested_amount > initiating_account_adapter.balance
      add_message :error, "You do not have enough money in your account for this transaction"
      return
    end
  end

  def pre_process
    # setting the status as pending because it will be processed immediately - for both payments and payment orders
    payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
    payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))

    # updating the initiating account for the payment order and paymets
    payment_order.update(initiating_account_type: initiating_account.class.name)
    payment_order.payments.update_all(initiating_account_id: initiating_account.id, initiating_account_type: initiating_account.class.name)
  end


  def process

    # now pass to the Create operation
    op = BankTransfer::YesBank::Create.(user, bank_payment_request: bank_payment_request)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    # update the bank_payment_request to credited
    bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited))
  end

  def post_process
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