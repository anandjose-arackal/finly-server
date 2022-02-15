class BbpsBillStatusChecker < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    BbpsBillStatusChecker::Background.perform_async

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end
 
  class BbpsBillStatusChecker::Background
    include Sidekiq::Worker
    sidekiq_options queue: :payments_critical_queue, retry: 5

    def perform
      ActsAsTenant.without_tenant do
        payments = Payment.where(parent_type: "BbpsBill").where(payment_status_id: [PaymentStatus.id_for(:processing), PaymentStatus.id_for(:possible_failure)])
        payments.each do |payment|
          ActsAsTenant.with_tenant payment.company do
            bill = payment.parent
            next unless bill.present? && bill.class.name == "BbpsBill"
            bank_transaction = payment.bbps_bank_transaction
            order_number = bank_transaction.order_number
              params = {
                  order_number: order_number,
                  biller_id: bill.biller.biller_id,
                  #txn_ref_id: payment&.bbps_bank_transaction&.bbps_ref_id
              }
            Bbps::TransactionStatus.call_async({params: params, current_user: payment.initiating_user}, {wait: true}) do |op|
              op.success do |result|
                puts "SUCCESS: #{result}"
                payment.update(payment_status_id: PaymentStatus.id_for(:completed))
                payment.payment_order.update_order_status
                payment.payment_order.update_processed_amount
                bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
                bill.update(status_id: BbpsBillStatus.id_for(:paid))
                
                # Update last paid on date for subscription
                # transaction_date = result&.transaction_details&.
                transaction_details = result
                date = transaction_details&.dig("txn_date")
                parsed_datetime = DateUtils.parse_datetime(date)
                if date.present? && parsed_datetime.present?
                  payment&.parent&.update(paid_at: parsed_datetime)
                  payment&.parent&.subscription&.update(last_paid_at: parsed_datetime)
                end

                payment.system_messages.destroy_all
                payment.system_messages.create(
                  system_message_type_id: SystemMessageType.id_for(:success),
                  content: "Payment Successfully Completed."
                )
              end
              op.error do |result|
                puts "Error: #{result}"
                payment.update(payment_status_id: PaymentStatus.id_for(:failed))
                bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
                bill.update(status_id: BbpsBillStatus.id_for(:approved))

                payment.system_messages.destroy_all
                # add error message to the ticket
                error_message = result['response']
                payment.system_messages.create(
                  system_message_type_id: SystemMessageType.id_for(:error),
                  content: "#{error_message}."
                )
                # credit the amount back to the accout if already not credited.

                # get all the finly transaction_details, ( debit - credit == 1 )
                debit_transactions_count = FinlyTransaction.where(payment_id: payment.id, transaction_type_id: TransactionType.id_for(:debit)).count
                credit_transactions_count = FinlyTransaction.where(payment_id: payment.id, transaction_type_id: TransactionType.id_for(:credit)).count

                if debit_transactions_count - credit_transactions_count >= 1
                  adapter = AccountManager::Base.new()
                  credit_adapter = adapter.send(:retrieve_adapter , payment.initiating_account, payment )

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
      end
    end
  end
end