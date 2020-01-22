class AssociateBankTransactionToPayment

  def self.process
    Payment.all.find_each do |payment|
      reference_transaction = payment.reference_resource
      reference_transaction.update(reference_payment_id: payment.id)
    end
  end
end