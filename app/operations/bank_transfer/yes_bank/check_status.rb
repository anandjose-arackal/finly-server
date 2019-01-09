# this operation will accept a particular bank transaction and checks its status if it's a
# Bank transaction that is in processing state

class BankTransfer::YesBank::CheckStatus < BankTransfer::YesBank::Base

  attr_accessor :bank_transaction, :company, :payment, :payment_request, :payment_order, :error_logger

  def self.call(bank_transaction)
    self.new(bank_transaction).run
  end

  def initialize(bank_transaction)
    self.bank_transaction = bank_transaction
    self.company = bank_transaction.company
    self.payment = bank_transaction.payment
    self.payment_order = self.payment&.payment_order
    self.error_logger = Logger.new("#{Rails.root}/log/transactions_msg_queue_errors.log")
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
        request_reference_number: bank_transaction.unique_request_number,
        company_id: bank_transaction.company_id,
        unique_request_number: bank_transaction.unique_request_number,
        transfer_type: bank_transaction.transfer_type
    }
    op = YesBankApi::Status::GetStatus.(params)
    if op.success?
      if Constants::YesBank::SUCCESSFUL_TRANSACTION_STATUSES.include?(op.request_status.upcase)
      # if true
        bank_reference_number = op.bank_reference_number
        bank_transaction.update(bank_reference_number: bank_reference_number) if bank_transaction.bank_reference_number.blank?
        handle_successful_transaction
      elsif Constants::YesBank::PROCESSING_TRANSACTION_STATUSES.include?(op.request_status.upcase)
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
        begin
          bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:processing))
        rescue => error
          self.error_logger.error("Following bank transaction has been orphaned: #{self.bank_transaction.id}")
          error.backtrace.each do |line|
            error_logger.error "\t #{line}"
          end
          Event::EAlert::Create.(nil, title: 'Bank Transaction without a payment', description: "We found an orphaned bank transaction - Details: #{bank_transaction.as_json}", subject: 'Bank Transaction without a Payment')
        end
        # destroying previous messages first, before adding the processing message
        self.payment&.system_messages.destroy_all
        self.payment&.system_messages.build(system_message_type_id: SystemMessageType.id_for(:info),
                                      content: "Payment processed. Awaiting credit confirmation").save
      elsif Constants::YesBank::FAILED_TRANSACTION_STATUSES.include?(op.request_status.upcase)
      # elsif true
        begin
          bank_transaction.payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        rescue => error
          self.error_logger.error("Following bank transaction has been orphaned: #{self.bank_transaction.id}")
          error.backtrace.each do |line|
            error_logger.error "\t #{line}"
          end
          Event::EAlert::Create.(nil, title: 'Bank Transaction without a payment', description: "We found an orphaned bank transaction - Details: #{bank_transaction.as_json}", subject: 'Bank Transaction without a Payment')
        end

        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))

        # destroying previous messages first, before adding the failure message
        # self.payment.system_messages.destroy_all # probably not a good idea to destroy previous messages because they contain data about why a particular payment failed

        # adding message regarding payment refund
        self.payment.system_messages.build(system_message_type_id: SystemMessageType.id_for(:error),
                                      content: "The amount will be refunded to your account shortly").save
        # creating a refund payment for this amount
        # the below will be executed only if the company is using Finly's nodal account for processing transactions
        unless self.company.current_account_connected?
          create_refund_payment
        end
        # nulling reimbursements that might have happened through this
        nullify_reimbursed_reports
      else
        # do nothing for now, will get back to this later
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
    if self.payment.completed?
      op = Event::EBankPaymentRequest::EPayment::CreditConfirm.(payment.initiating_user, payment: self.payment)
      execute_callback(self.payment)
    elsif payment.failed?
      execute_callback(self.payment)
    end
  end

  private

  def create_refund_payment
    admin_user = AdminUser.find_by(email: 'vivek.a@finly.io')
    original_debit_account = self.payment.initiating_account
    self.payment_request = ::PaymentRequest.(admin_user, nil, original_debit_account.class.name, :credit, :corporate_balance_refund, company_id: self.company.id)
    self.payment_request.add_payment_item(::PaymentRequest::PaymentItem.(nil, original_debit_account, self.bank_transaction.amount_value))

    op = AccountManager::Payments::PaymentProcessor.(user, {payment_request: payment_request})
    if op.success?
      refund_payment = op.payment_order.payments.first
      self.bank_transaction.update(refunded: true)
      refund_payment&.update(original_payment_for_refund_id: self.payment.id)
    else
      # op.payment_order.destroy
      add_message :error, op.messages[:error]
    end

    if self.payment.invoice.present?
      self.payment.invoice.update_invoice_status
    end
    # also update the status and processed amount of the payment order from here
    self.payment.payment_order.update_order_status
    self.payment.payment_order.update_processed_amount
  end

  def handle_successful_transaction
    if self.payment&.cash_on_hand_credit?
      init_payment_request
      # now execute the payment that adds to the user's cash on hand
      op = AccountManager::Payments::PaymentProcessor.(self.payment.initiating_user, {payment_request: self.payment_request})
      payment = op.payments.first
      payment.update(application: "em") # because this should show up in the settlement history of this particular user
    end
    # now mark the respective bank transaction and payment as completed
    if self.payment.blank?
      Event::EAlert::Create.(nil, title: 'Bank Transaction without a payment', description: "We found an orphaned bank transaction - Details: #{bank_transaction.as_json}", subject: 'Bank Transaction without a Payment')
    end
    bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
    self.payment&.update(payment_status_id: PaymentStatus.id_for(:completed))
    if self.payment&.note.blank? || self.payment&.note == 'Reimbursement processed. Awaiting credit confirmation'
      self.payment&.update(note: "Payment credit confirmed")
    end

    # updating the status of the invoice against successful credit of this
    if self.payment&.invoice.present?
      self.payment&.invoice&.update_invoice_status
    end

    # marking the payment order as completed if all the payments in it are completed
    if self.payment&.payment_order&.payments&.pluck(:payment_status_id)&.uniq == [PaymentStatus.id_for(:completed)]
      self.payment&.payment_order&.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
    end

    # update the status of the payment order after this
    self.payment&.payment_order&.update_order_status

    self.payment&.system_messages&.destroy_all # deleting the previous system messages
  end

  def init_payment_request
    receiving_user = payment.receiving_user
    amount = payment.amount_value
    receiving_account = receiving_user.user_pockets.cash_pockets_only.first # todo - jugaad, needs refactoring
    self.payment_request = ::PaymentRequest.(payment.initiating_user, nil, (receiving_account&.class&.name), :credit, :advance)
    self.payment_request.add_payment_item(::PaymentRequest::PaymentItem.(receiving_user, receiving_account, amount, note: self.payment.note))
  end

  def nullify_reimbursed_reports
    # setting their status as approved, and disassociating the reimbursement payment with these reports
    reports = self.payment.reimbursed_reports
    reports.each do |report|
      report.update(report_status_id: ReportStatus.id_for(:approved), reimbursement_id: nil)
    end
  end

  def execute_callback(payment)
    post_params = {
        payment_id: payment.id,
        payment_amount: payment.amount_value,
        note: payment.note,
        status: payment.payment_status&.name,
        receiving_account: {
            receiving_account_type: "BankAccount",
            receiving_account_id: payment.receiving_account&.id,
            receiving_account_number: payment.receiving_account&.account_number,
            receiving_account_ifsc: payment.receiving_account&.ifsc
        },
        bank_reference_number: payment.reference_resource&.bank_reference_number
    }
    if payment.failed?
      post_params[:errors] = payment.system_messages.errors.pluck(:content).to_sentence
    end
    # this particular type of payment will always have an initiating user because it is a vendor payment / reimbursement payment
    company = payment.initiating_user&.company
    op = Webhook::Process.(nil, {company: company, body: post_params, web_hook_event_id: WebHookEvent.id_for('vendor_payments.credit_confirmation')})
    # creating the webhook track based on the response of the particular operation
    if company.web_hooks.present?
      callback_track = CallbackTrack.new(company: company, entity: payment, request: post_params.to_s)
      if op.success?
        callback_track.update(success: true, response: (op.body rescue nil))
      else
        callback_track.update(success: false, response: (op.body rescue nil))
      end
    end
  end

end