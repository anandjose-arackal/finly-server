# Once approved, this operation will take the payment order and perform a credit for it
# the initiating account can be changed at this stage as well

class BankTransfer::PaymentRequest::Review::Credit < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :initiating_account, :auto_credit

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
    self.auto_credit = true
    # if bank_payment_request&.payment_order&.initiating_account&.id == user.bank_wallet.id
    #   self.auto_credit = true
    # end
    self.initiating_account = retrieve_initiating_account
  end

  def validate
    # no validations as the payment request can be credited at any state
  end

  def pre_process
    # setting the status as pending because it will be processed immediately - for both payments and payment orders
    payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:pending))
    payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:pending))
  end


  def process
    # first update the payment order to the initiating account that's being requested
    payment_order.payments.update_all(initiating_account_id: initiating_account.id, initiating_account_type: initiating_account.class.name)

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
        # do nothing?
    end
  end

end