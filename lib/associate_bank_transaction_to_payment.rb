class AssociateBankTransactionToPayment

  def self.process
    # the below will update all reference transactions with their associated payment IDs
    Payment.all.find_each(batch_size: 1000) do |payment|
      reference_transaction = payment.reference_resource
      puts "Payment ID: #{payment.id} - #{reference_transaction&.class&.name} with ID: #{reference_transaction&.id}"
      payment.update_columns(utr: reference_transaction.try(:utr))
      reference_transaction&.update_columns(reference_payment_id: payment.id)
    end
  end
end