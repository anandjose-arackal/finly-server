# this takes a list of spurious payments in the system - for example things like payments that are in progress
# and such and handles them accordingly
class FixSpuriousPayments < ActiveJob::Base

  spurious_payments = Payment.where(payment_status_id: [PaymentStatus.id_for(:pending), PaymentStatus.id_for(:in_progress)]).where('created_at <= ?', (DateTime.now - 1.hour)).where(receiving_account_type: "BankAccount")
  spurious_payments.each do |payment|
    # case 1 - if the payment is in pending state because of the bank account being on hold or disabled
    if payment.receiving_account_type == "BankAccount" && (payment.receiving_account.on_hold? || payment.receiving_account.disabled?)
      # In this case there is nothing to be done, and just go next
      next
    end

    # case 2 - where the payment is still in progress or pending state, and has an associated bank transaction with it
    if payment.reference_resource.present? && (payment.reference_resource_type == "BankTransaction")
      bank_transaction = payment.reference_resource
      params = {
          request_reference_number: bank_transaction.unique_request_number,
          company_id: bank_transaction.company_id,
          unique_request_number: bank_transaction.unique_request_number,
          transfer_type: bank_transaction.transfer_type
      }
      op = YesBankApi::Status::GetStatus.(params)
      if op.success? && op.bank_reference_number.present?
        # update the bank transaction as processing, and wait for CheckStatus to take care of things
        if bank_transaction.bank_reference_number.blank?
          bank_transaction.update(bank_reference_number: op.bank_reference_number)
        end
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing))
      end
    end

    # case 3 - when the payment is in pending state and has no bank transaction associated with it - mark the payment as failed for retrying later
    if payment.reference_resource.blank? && (payment.receiving_account_type == "BankAccount")
      payment.update(payment_status_id: PaymentStatus.id_for(:failed))
    end
  end
end