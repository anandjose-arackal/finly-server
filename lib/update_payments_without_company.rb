class UpdatePaymentsWithoutCompany

  def self.run
    payments = Payment.where(company_id: nil)
    payments.each do |payment|
      puts "Updating Payment ID #{payment.id}"
      payment.update_columns(payment.payment_order&.company_id)
    end
  end
end