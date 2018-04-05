# this operation will transfer the funds from the company pool account
# to the respective configured current account of the company. It uses
# the same APIs and operation as any regular vendor payment
class Event::ECompanyFundsAutoTransfer::Transfer < Event::ECompanyFundsAutoTransfer::Base

  attr_accessor :company, :collect_credit_account, :payment_request, :auto_transfer_config,
                :account_balance, :transferable_amount, :transfer_mode, :transfer_mode

  def pre_validate
  end

  def init
    self.company = params[:company]
    self.collect_credit_account = self.company.collect_credit_account
    self.auto_transfer_config = company.collect_auto_transfer_config
    self.transfer_mode = auto_transfer_config.transfer_mode.to_s.upcase

    adapter = AccountManager::YesBankCompanyAccount::YesBankCompanyAccountAdapter.new(company.yes_bank_company_account)
    self.account_balance = adapter.balance

    self.transferable_amount = get_transferable_amount
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

    unless transfer_mode_valid?(transferable_amount)
      add_message :error, "Funds transfer cannot proceed with #{transfer_mode} for amount #{transferable_amount}"
      #todo mailer for user to let them know automatic transfer didin't go through
    end

    # checking if the account number and IFSC code for the collect account are present
    unless self.collect_credit_account.account_number.present? && self.collect_credit_account.ifsc.present?
      add_message :error, "The company credit account hasn't been correctly configured"
      return
    end
  end

  def pre_process
    # set the amount to be transferred to the current account here

  end

  def process
    self.payment_request = build_payment_request
    # calling the payment processor to complete the transfer using adapters
    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: self.payment_request, bank_transfer_type: self.transfer_mode, background: false})
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
    #todo sreeram: instead of user nil is passed, has to be taken care of
    payment_request = ::PaymentRequest.call(nil, self.company.yes_bank_company_account,
                                            BankAccount.name, :credit,
                                            :collect_funds_withdrawal,
                                            {bank_transfer_type: self.transfer_mode,
                                                    company_id: company.id}
                                            )
    #todo sreeram: instead of user nil is passed, has to be taken care of
    payment_request.add_payment_item(::PaymentRequest::PaymentItem.call(nil, self.collect_credit_account, self.transferable_amount))
    payment_request
  end

  def get_transferable_amount
    threshold = auto_transfer_config.threshold_amount.value
    type = auto_transfer_config.amount_transfer_type

    amount = 0

    if type == 'excess'
      amount = threshold <= account_balance ? 0 : (account_balance - threshold)
    elsif type == 'all'
      amount = threshold < account_balance ? 0 : account_balance
    end
    amount
  end

  def transfer_mode_valid?(amount)
    #todo put logic to check against Payment mode and amount
    true
  end
end

