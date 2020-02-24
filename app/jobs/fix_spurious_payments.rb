# this takes a list of spurious payments in the system - for example things like payments that are in progress
# and such and handles them accordingly
class FixSpuriousPayments < ApplicationJob

  def perform
    spurious_payments = Payment.where(payment_status_id: [PaymentStatus.id_for(:pending), PaymentStatus.id_for(:in_progress)]).where('updated_at <= ?', (DateTime.now - 1.day)).where(receiving_account_type: "BankAccount")
    spurious_payments.each do |payment|

      bpr = payment.reload.payment_order.try(:bank_payment_request)
      # if the bank payment request doesn't exist or has not been credited, skip to the next payment
      next if bpr.blank? || !bpr.credited?
      # now find the latest credit trail and check to ensure it wasn't credited in the last 1 day
      # if it was, then skip to the next payment because we have nothing to do here
      credit_trail = bpr.trails.where(action_id: TrailAction.id_for(:credit)).reorder(created_at: :desc).first
      # next if (credit_trail.blank? && !payment.api_initiated) || (credit_trail&.created_at > (DateTime.now - 1.day))

      unless payment.api_initiated?
        next if credit_trail.blank? || (credit_trail&.created_at > (DateTime.now - 1.day))
      end

      # case 1 - if the payment is in pending state because of the bank account being on hold or disabled
      if payment.receiving_account_type == "BankAccount" && (payment.receiving_account.on_hold? || payment.receiving_account.disabled?)
        # In this case there is nothing to be done, and just go next
        next
      end

      # case 2 - where the payment is still in progress or pending state, and has an associated bank transaction with it
      # in this case we just set the payment status to possible failure and let the status checker handle the rest
      bts = payment.reference_resources
      if bts.present?
        bts.update(transfer_status_id: BankTransferStatus.id_for(:possible_failure))
        payment.update(payment_status_id: PaymentStatus.id_for(:possible_failure))
      end

      # case 3 - when the payment is in pending state and has no bank transaction associated with it - mark the payment as failed for retrying later
      if payment.reference_resources.blank? && (payment.receiving_account_type == "BankAccount")
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      end
    end
  end

end