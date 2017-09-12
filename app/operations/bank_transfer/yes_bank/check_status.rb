# this operation will accept a particular bank transaction and checks its status if it's a
# Bank transaction that is in processing state

class BankTransfer::YesBank::CheckStatus < BankTransfer::YesBank::Base

  attr_accessor :bank_transaction, :company, :payment, :payment_request

  def self.call(bank_transaction)
    self.new(bank_transaction).run
  end

  def initialize(bank_transaction)
    self.bank_transaction = bank_transaction
    self.company = bank_transaction.company
    self.payment = bank_transaction.payment
  end

  def authorized_user_types
    []
  end

  def pre_validate
    if bank_transaction.nil?
      add_message :error, "Invalid parameters"
    end
  end

  def init

  end

  def validates
    # confirm that the bank transaction is, in fact in processing state
    unless bank_transaction.processing?
      add_message :error, "This transaction is not in processing state"
      return
    end
  end

  def process
    params = {
        request_reference_number: bank_transaction.unique_request_number
    }
    op = YesBankApi::Status::GetStatus.(params)
    if op.success?
      if Constants::YesBank::SUCCESSFUL_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        handle_successful_transaction
      elsif Constants::YesBank::PROCESSING_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
        bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:processing))
      elsif Constants::YesBank::FAILED_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))

        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "The amount will be refunded to your bank account shortly").save
        # creating a refund payment for this amount
        create_refund_payment
      else
        # do nothing?
      end
    end

  end

  private

  def create_refund_payment
    admin_user = AdminUser.find_by(email: 'vivek.a@finly.io')
    self.payment_request = PaymentRequest.(admin_user, nil, company.yes_bank_company_account.class.name, :credit, :corporate_balance_refund, company_id: self.company.id)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(nil, company.yes_bank_company_account, self.bank_transaction.amount_value))

    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
    if op.success?
      self.bank_transaction.update(refunded: true)
      # add system message indicating that this is a refund
    else
      # op.payment_order.destroy
      add_message :error, op.messages[:error]
    end
  end

  def handle_successful_transaction
    if payment&.cash_on_hand_credit?
      init_payment_request
      # now execute the payment that adds to the user's cash on hand
      AccountManager::Payments::PaymentProcessor(payment.initiating_user, {payment_request: self.payment_request})
    end
    # now mark the respective bank transaction and payment as completed
    bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
    bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:completed))
  end

  def init_payment_request
    receiving_user = payment.receiving_user
    amount = payment.amount_value
    receiving_account = receiving_user.cash_on_hand
    self.payment_request = PaymentRequest.(payment.initiating_user, nil, (receiving_account&.class&.name), :credit, :advance)
    self.payment_request.add_payment_item(PaymentRequest::PaymentItem.(receiving_user, receiving_account, amount, note: self.payment.note))
  end

end