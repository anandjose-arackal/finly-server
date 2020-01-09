class BbpsBillStatusChecker < ApplicationJob

  def perform
    payments = Payment.where(parent_type: "BbpsBill").where(payment_status_id: [PaymentStatus.id_for(:processing), PaymentStatus.id_for(:possible_failure)])
    payments.each do |payment|
      bill = payment.parent
      next unless bill.present? && bill.class.name == "BbpsBill"
      order_number = bill.order_number
      bank_transaction = payment.reference_resource
      params = {
          order_number: order_number
      }
      Bbps::TransactionStatus.({params: params, "current_user" => payment.initiating_user}) do |op|
        op.success do |result|
          puts "SUCCESS: #{result}"
          payment.update(payment_status_id: PaymentStatus.id_for(:completed))
          payment.payment_order.update_order_status
          payment.payment_order.update_processed_amount
          bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed))
        end
        op.error do |result|
          puts "Error: #{result}"
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
          bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
          bill.update(status_id: BbpsBillStatus.id_for(:approved))
        end
        op.failure do |result|
          puts "Failure: #{result}"
          # log this response somewhere and see what the issue is:
          # TODO - add mailer here to send to sreeram.nr@finly.io kumar.abinash@finly.io
          # not updating the bill status here because it will depend on the final
          # status of the payment, and possible failure isn't a final status
        end
      end
    end
  end
end