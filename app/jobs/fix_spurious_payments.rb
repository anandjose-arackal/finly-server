# this takes a list of spurious payments in the system - for example things like payments that are in progress
# and such
class FixSpuriousPayments < ActiveJob::Base

  # spurious_payments = Payment.where(payment_status_id: [PaymentStatus.id_for(:pending), PaymentStatus.id_for(:in_progress)])
  # spurious_payments.each do |payment|
  #   # case 1 - where the payment is still in progress or pending state, and has an associated bank transaction with it
  #   if payment.reference_resource.present? && (payment.reference_resource_type == "BankTransaction")
  #     bank_transaction = payment.reference_resource
  #     params = {
  #         request_reference_number: bank_transaction.unique_request_number,
  #         company_id: bank_transaction.company_id,
  #         unique_request_number: bank_transaction.unique_request_number,
  #         transfer_type: bank_transaction.transfer_type
  #     }
  #     op = YesBankApi::Status::GetStatus.(params)
  #     if op.success?
  #       # update the bank transaction as processing, and wait for CheckStatus to take care of things
  #       bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
  #     end
  #   end
  #
  #   # case 2 - when the payment is in pending state and has not bank transaction associated with it
  #   if payment.reference_resource.blank? && (payment.receiving_account_type == "BankAccount")
  #     payment.update(payment_status_id: PaymentStatus.id_for(:failed))
  #   end
  # end
end