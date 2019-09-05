# only completed neft transactions will come here, because they have been confirmed as successful
# by the API, but don't have the UTR so need to get that manually

class BankTransfer::Icici::Transactions::CheckStatusNeft < BaseOperation

  attr_accessor :bank_transaction, :company, :payment, :payment_order

  def self.call(bank_transaction)
    self.new(bank_transaction).run
  end

  def initialize(bank_transaction)
    self.bank_transaction = bank_transaction
    self.company = bank_transaction.company
    self.payment = bank_transaction.payment
    self.payment_order = self.payment&.payment_order
  end

  def validate
    unless self.bank_transaction.completed?
      add_message :error, "This transaction is not in completed state"
      return
    end

    unless self.bank_transaction.neft?
      add_message :error, "This is not a NEFT payment"
      return
    end
  end

  def process
    statement_entry = self.company.icici_statements.find_by(request_id: self.bank_transaction.unique_request_number)
    if statement_entry.present?
      # eg. if the remarks are: "INF/021341686931/FINLYRGS94365231618"
      # 021341686931 - is the UTR
      # FINLYRGS94365231618 is the request ID
      utr = statement_entry.remarks.split("/").last(2).first rescue ""
      # per ICICI's instruction "1DC" needs to get added to this number for the full UTR
      utr += "1DC"
      self.bank_transaction.update(utr: utr)

      self.payment.update(payment_status_id: PaymentStatus.id_for(:completed))
      self.payment.system_messages.destroy_all
      if self.payment&.invoice.present?
        self.payment&.invoice&.update_invoice_status
      end
      self.payment_order.update_order_status
      self.payment_order.update_processed_amount
    end
  end

end
