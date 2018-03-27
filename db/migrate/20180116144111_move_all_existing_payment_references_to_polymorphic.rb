class MoveAllExistingPaymentReferencesToPolymorphic < ActiveRecord::Migration
  def change
    Payment.where.not(invoice_id: nil).each do |payment|
      invoice = payment.invoice
      payment.update(parent: invoice)
    end
  end
end
