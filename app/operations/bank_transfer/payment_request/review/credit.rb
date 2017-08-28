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
    if bank_payment_request&.payment_order&.initiating_account&.id == user.bank_wallet.id
      self.auto_credit = true
    end
    self.initiating_account = retrieve_initiating_account
  end

  def validate
    unless bank_payment_request.can_credit? || auto_credit
      add_message :error, "Payment Order cannot be credited at this time"
      return
    end

    if auto_credit
      unless bank_payment_request.owner_id == user.id
        add_message :error, "Only request owners can perform this operation"
      end
    end
  end


  def process
    # first update the payment order to the initiating account that's being requested
    payment_order.payments.update_all(initiating_account_id: initiating_account.id, initiating_account_type: initiating_account.class.name)

    # now pass to the Create operation
    op = BankTransfer::YesBank::Create.(user, bank_payment_request: bank_payment_request)
    debugger
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
    # todo - as of now cannot be changed during credit, but will be picked up directly from the payment order itself
    # case params[:initiating_account_type]
    #   when 1, '1'
    #     # i.e. company credits
    #     # check if the user has access to company credits first
    #     if user.company_admin?
    #       self.initiating_account = user.company.yes_bank_company_account
    #     else
    #       self.initiating_account = user.bank_wallet
    #     end
    #   when 2, '2'
    #     # i.e. the crediting user's wallet
    #     self.initiating_account = user.bank_wallet
    #   when 3, '3'
    #     # i.e. the owner's wallet
    #     self.initiating_account = payment_order.initiating_account
    #   else
    #     # do nothing, ha
    # end
    self.bank_payment_request.payment_order.initiating_account
  end

end