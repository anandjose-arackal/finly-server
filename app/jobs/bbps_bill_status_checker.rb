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
          end
          op.failure do |result|
            puts "Failure: #{result}"
            Event::EAlert::Create.(nil, title: 'BBpsBills Status check failure', description: "#{result}", subject: 'BBpsBills Status check failure')
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