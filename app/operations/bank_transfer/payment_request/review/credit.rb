# Once approved, this operation will take the payment order and perform a credit for it
# the initiating account can be changed at this stage as well

class BankTransfer::PaymentRequest::Review::Credit < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :initiating_account


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


  def validate
    unless bank_payment_request.can_credit? || params[:auto_credit]
      add_message :error, "Payment Order cannot be credited at this time"
      return
    end
  end

  def init
    super
    self.initiating_account = retrieve_initiating_account
  end

  def process
    # first update the payment order to the initiating account that's being requested
    payment_order.payments.update_all(initiating_account: initiating_account)

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
    add_message :error, "Payment Order credited successfully!"
  end

  private

  def retrieve_initiating_account
    case params[:initiating_account_type]
      when 1, '1'
        # i.e. company credits
        # check if the user has access to company credits first
        if user.company_admin?
          self.initiating_account = user.company.yes_bank_company_account
        else
          self.initiating_account = user.bank_wallet
        end
      when 2, '2'
        # i.e. the crediting user's wallet
        self.initiating_account = user.bank_wallet
      when 3, '3'
        # i.e. the owner's wallet
        self.initiating_account = payment_order.initiating_account
    end
  end

end