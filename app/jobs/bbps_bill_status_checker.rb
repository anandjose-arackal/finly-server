class BbpsBillStatusChecker

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    BbpsBillStatusChecker::Background.perform_async

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

  class BbpsBillStatusChecker::Background
    include Sidekiq::Worker
    sidekiq_options queue: :payments_critical_queue

    def perform
      payments = Payment.where(parent_type: "BbpsBill").where(payment_status_id: [PaymentStatus.id_for(:processing), PaymentStatus.id_for(:possible_failure)])
      payments.each do |payment|
        bill = payment.parent
        next unless bill.present? && bill.class.name == "BbpsBill"
        order_number = bill.order_number
        bank_transaction = payment.bbps_bank_transaction
        params = {
            order_number: order_number
        }
        Bbps::TransactionStatus.call_async({params: params, "current_user" => payment.initiating_user}, {wait: true}) do |op|
          op.success do |result|
            puts "SUCCESS: #{result}"
            payment.update(payment_status_id: PaymentStatus.id_for(:completed))
            payment.payment_order.update_order_status
            payment.payment_order.update_processed_amount
            bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
            bill.update(status_id: BbpsBillStatus.id_for(:paid))

            # Update last paid on date for subscription
            # transaction_date = result&.transaction_details&.
            transaction_details = JSON.parse result.transaction_details rescue {}
            date = transaction_details&.dig("TxnStatusComplainResp")&.dig("txnList")&.dig("txnDetail")&.first&.dig("txnDate")
            parsed_datetime = DateUtils.parse_datetime(date)
            if date.present? && parsed_datetime.present?
              payment&.parent&.update(paid_at: parsed_datetime)
              payment&.parent&.subscription&.update(last_paid_at: parsed_datetime)
            end
          end
          op.error do |result|
            puts "Error: #{result}"
            payment.update(payment_status_id: PaymentStatus.id_for(:failed))
            bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
            bill.update(status_id: BbpsBillStatus.id_for(:approved))
            # credit the amount back to the accout if already not credited.

            # get all the finly transaction_details, ( debit - credit == 1 )
            debit_transactions_count = FinlyTransaction.where(payment_id: payment.id, transaction_type_id: TransactionType.id_for(:debit)).count
            credit_transactions_count = FinlyTransaction.where(payment_id: payment.id, transaction_type_id: TransactionType.id_for(:credit)).count

            if debit_transactions_count - credit_transactions_count == 1
              adapter = AccountManager::Base.new()
              credit_adapter = adapter.send(:retrieve_adapter , payment.initiating_account, payment )

              payment.system_messages.destroy_all
              # add error message to the ticket
              error_message = result['error_desc']
              payment.system_messages.create(
                system_message_type_id: SystemMessageType.id_for(:error),
                content: "#{error_message}."
              )
              credit_adapter.credit(payment, {})
            end

          end
          op.failure do |result|
            puts "Failure: #{result}"
            Event::EAlert::Create.(nil, title: 'BbpsBills Status check failure', description: "#{result}", subject: 'BbpsBills Status check failure')
            # log this response somewhere and see what the issue is:
            # TODO - add mailer here to send to sreeram.nr@finly.io kumar.abinash@finly.io
            # not updating the bill status here because it will depend on the final
            # status of the payment, and possible failure isn't a final status
          end
        end
      end
    end


    def credit_for_failed_payment payment
      company = payment&.company
      account = company.utility_bills_account
      return if company.blank?
      return if account.blank?

      success = false
      opening_balance = account.balance_value
      balance_amount = account.balance
      balance_amount.with_lock do
      balance_amount.value += payment.amount_value
      success = balance_amount.save
      end
      closing_balance = account.balance_value

      type_id = TransactionType.id_for(:credit)
      status_id = TransactionStatus.id_for(:success)
      currency_id = Currency.id_for(:INR)
      params = { 
      transaction_type_id: type_id,
      status_id: status_id,
      amount_attributes: { value: payment.amount_value, currency_id: currency_id },
      payment_purpose_id: payment.payment_purpose_id, 
      opening_balance_attributes: { value: opening_balance, currency_id: currency_id },
      closing_balance_attributes: { value: closing_balance, currency_id: currency_id },
      associated_transaction: payment.reference_resources.first,
      payment: payment,
      company_id: company.id, 
      date: DateTime.now 
      }
      transaction = account.finly_transactions.create params
    end

  end
end