# Once approved, this operation will take the payment order and perform a credit for it
# the initiating account can be changed at this stage as well

class BankTransfer::PaymentRequest::Review::Credit < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :initiating_account, :initiating_account_adapter, :view_role

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
    # updating the initiating account for the payment order and payments
    payment_order.update(initiating_account_type: initiating_account.class.name)
    payment_order.payments.update_all(initiating_account_id: initiating_account.id, initiating_account_type: initiating_account.class.name)
  end


  def process

    # now pass to the Create operation
    op = BankTransfer::YesBank::Create.(user, bank_payment_request: bank_payment_request)
    if op.success?
      # update the bank_payment_request to credited
      bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited))
      # create a trail to show that the BPR was credited
      bank_payment_request.bank_payment_request_trails.create action_user: user,
                                                              action_user_role_id: self.view_role,
                                                              action_id: BankPaymentRequestTrailAction.id_for(:credit),
                                                              modified_user_id: nil,
                                                              modified_user_role_id: nil
    else
      add_message :error, op.messages[:error]
      bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:failed))
      return
    end
  end

  def post_process
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:credit)

    Event::EBankPaymentRequest::Credit.(user, bank_payment_request: bank_payment_request)

    # since credit has been initiated for all these vendors, make them authorized (if they're users, they're authorized by default)
    self.payment_order.payments.each do |payment|
      if payment.receiving_account.is_a?(BankAccount) && payment.receiving_account.account_owner.is_a?(YesBankVendor)
        payment.receiving_account.account_owner.update(authorized: true)
      end
    end

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