# this operation will accept a particular bank transaction and checks its status if it's a
# Bank transaction that is in processing state

class BankTransfer::YesBank::CheckStatus < BankTransfer::YesBank::Base

  attr_accessor :bank_transaction, :company, :payment, :payment_request, :payment_order

  def self.call(bank_transaction)
    self.new(bank_transaction).run
  end

  def initialize(bank_transaction)
    self.bank_transaction = bank_transaction
    self.company = bank_transaction.company
    self.payment = bank_transaction.payment
    self.payment_order = payment&.payment_order
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

  def validate
    # confirm that the bank transaction is, in fact in processing state
    unless bank_transaction.processing? || bank_transaction.possible_failure?
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
      # if true
        handle_successful_transaction
      elsif Constants::YesBank::PROCESSING_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
        bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:processing))
      elsif Constants::YesBank::FAILED_TRANSACTION_STATUSES.include?(op.request_status.upcase)
      # elsif true
        bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))

        # destroying previous messages first, before adding the failure message
        payment.system_messages.destroy_all
        # adding message regarding payment refund
        payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "The amount will be refunded to your account shortly").save
        # creating a refund payment for this amount
        create_refund_payment
        # nulling reimbursements that might have happened through this
        nullify_reimbursed_reports
      else
        # do nothing?
      end
    end

  end

  def post_process
    # here check if the payment order has associated bank payment requests and accordingly send notification
    if payment_order.bank_payment_request.present?
      # now check if all the payments in this order are either successes or failures.
      # i.e. none processing or awaiting credit confirmation
      completed = true
      bank_payment_request = payment_order.bank_payment_request
      payment_order.payments.each do |payment|
        unless [PaymentStatus.id_for(:completed), PaymentStatus.id_for(:failed)].include?(payment.payment_status_id)
          completed = false
        end
      end
      if completed
        # this will trigger the mailer and notification that a particular credit has been successfully completed
        Event::EBankPaymentRequest::CreditConfirm.(bank_payment_request.owner, bank_payment_request: bank_payment_request)
      end
    end

    # trigger event for sending mailer to the receiver of the payment
    if payment.completed?
      op = Event::EBankPaymentRequest::EPayment::CreditConfirm.(payment.initiating_user, payment: self.payment)
    end
  end

  private

  def create_refund_payment
    admin_user = AdminUser.find_by(email: 'vivek.a@finly.io')
    original_debit_account = self.payment.initiating_account
    self.payment_request = ::PaymentRequest.(admin_user, nil, original_debit_account.class, :credit, :corporate_balance_refund, company_id: self.company.id)
    self.payment_request.add_payment_item(::PaymentRequest::PaymentItem.(nil, original_debit_account, self.bank_transaction.amount_value))

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
      AccountManager::Payments::PaymentProcessor.(self.payment.initiating_user, {payment_request: self.payment_request})
    end
    # now mark the respective bank transaction and payment as completed
    bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
    self.payment.update(payment_status_id: PaymentStatus.id_for(:completed))
    if self.payment.note.blank? || payment.note == 'Reimbursement processed. Awaiting credit confirmation'
      self.payment.update(note: "Payment credit confirmed")
    end
    self.payment.system_messages.destroy_all # deleting the previous system messages
  end

  def init_payment_request
    receiving_user = payment.receiving_user
    amount = payment.amount_value
    receiving_account = receiving_user.cash_on_hand
    self.payment_request = ::PaymentRequest.(payment.initiating_user, nil, (receiving_account&.class&.name), :credit, :advance)
    self.payment_request.add_payment_item(::PaymentRequest::PaymentItem.(receiving_user, receiving_account, amount, note: self.payment.note))
  end

  def nullify_reimbursed_reports
    # setting their status as approved, and disassociating the reimbursement payment with these reports
    reports = payment.reimbursed_reports
    reports.each do |report|
      report.update(report_status_id: ReportStatus.id_for(:approved), reimbursement_id: nil)
    end
  end

end