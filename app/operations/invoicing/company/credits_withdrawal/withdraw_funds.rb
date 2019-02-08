# this operation will transfer the funds from the company pool account
# to the respective configured current account of the company. It uses
# the same APIs and operation as any regular vendor payment

class Invoicing::Company::CreditsWithdrawal::WithdrawFunds < Invoicing::Company::Base

  attr_accessor :company, :collect_credit_account, :payment_request,
                :transferable_amount, :transfer_mode, :transfer_mode

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
    self.company = user.company
    self.collect_credit_account = self.company.collect_credit_account
    self.transfer_mode = params[:transfer_mode].to_s.upcase
  end

  def validate
    if self.collect_credit_account.blank?
      add_message :error, "Company credit account not found"
      return
    end

    if self.transfer_mode.blank?
      add_message :error, "No transfer mode specified. Please select how you want to transfer the money"
      return
    end

    # checking if the account number and IFSC code for the collect account are present
    unless self.collect_credit_account.account_number.present? && self.collect_credit_account.ifsc.present?
      add_message :error, "The company credit account hasn't been correctly configured"
      return
    end
  end

  def pre_process
    # set the amount to be transferred to the current account here
    self.transferable_amount = params[:transferable_amount].to_f
    if self.transferable_amount == 0
      adapter = AccountManager::YesBankCompanyAccount::YesBankCompanyAccountAdapter.new(user.company.yes_bank_company_account)
      self.transferable_amount = adapter.balance
    end
  end

  def process
    self.payment_request = build_payment_request
    # calling the payment processor to complete the transfer using adapters
    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: self.payment_request, bank_transfer_type: self.transfer_mode, background: true})
    if op.success?
      payment = op.payment_order.payments.first
      if payment.reload.processing?
        payment.system_messages.create(content: "Transfer processed. Awaiting credit confirmation",
                                       system_message_type_id: SystemMessageType.id_for(:error)
        )
        payment.update(note: "Transfer processed. Awaiting credit confirmation")
      end
    else
      add_message :error, op.messages[:error]
      return
    end
  end

  def post_process
    add_message :success, "Transfer to credit account processed successfully!"
  end

  private

  def build_payment_request
    payment_request = ::PaymentRequest.call(user, self.company.yes_bank_company_account, BankAccount.name, :credit, :collect_funds_withdrawal, {bank_transfer_type: self.transfer_mode, company_id: user.company_id})
    payment_request.add_payment_item(::PaymentRequest::PaymentItem.call(user, self.collect_credit_account, self.transferable_amount))
    payment_request
  end
end

