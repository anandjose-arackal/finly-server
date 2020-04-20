class CheckForFailedNeftTransactions

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------"

    Company.all.each do |company|
      # first retrieve all statements for the past 2 days
      past_two_days_statements = IciciStatement.where(company_id: company.id).where('txn_date >= ? AND txn_date <= ?', (Date.today - 30.days), Date.tomorrow)
      past_two_days_statements.each do |entry|
        # SAMPLE REMARKS FORMAT FOR NEFT RETURN
        # NEFT-RETURN-21954163111DC-S S REFRIGERATION-BENEFICIARY NAME DIFFERES  R05
        # NEFT-RETURN-21904351411DC-NANI SAMADDAR-ACCOUNT DOES NOT EXIST  R03
        if entry.remarks.include?("NEFT-RETURN")
          utr = entry.remarks.split("-").third
        end

        # in case this entry does not have a remarks column, skip it
        next if utr.blank?

        # first making the UTR the same as the one we store in the DB
        utr = "0#{utr[0..(utr.length - 3)]}"

        # find the bank transaction that has the above UTR
        bank_transaction = IciciBankTransaction.find_by(utr: utr)

        # if the bank transaction doesn't exist, skip to the next one
        next if bank_transaction.blank?

        # retrieve the latest status of this transaction
        IciciBankApi::TransactionStatus.(bank_transaction)

        # now that we have the latest statuses, we can update the transactions and
        # the payment so that it reflects the latest status
        if bank_transaction.completed?
          bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))

          # also mark the associated payment as failed
          bank_transaction.reference_payment&.update(payment_status_id: PaymentStatus.id_for(:failed))
          bank_transaction.reference_payment&.system_messages.create(
              content: "This transaction was returned from NEFT servers",
              system_message_type_id: SystemMessageType.id_for(:error)).save
          bank_transaction.reference_payment&.payment_order&.update_order_status
        end
      end
    end

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

end