class AssociateBankTransactionToPayment

  def self.process
    # the below will update all reference transactions with their associated payment IDs
    Payment.all.find_each do |payment|
      reference_transaction = payment.reference_resource
      payment.update(utr: reference_transaction.try(:utr))
      reference_transaction.update(reference_payment_id: payment.id)
    end

  end
end