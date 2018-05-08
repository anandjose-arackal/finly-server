class Personalizer::Adapters::Company102::BankPaymentRequests102::Submit102::Validate < Personalizer::Adapters::Base

  attr_accessor :bank_payment_request

  def init
    self.bank_payment_request = self.op_instance.bank_payment_request
  end

  def validate
    # checking if all the payments have attachments
    self.bank_payment_request.payment_order.payments.each do |payment|
      invoice = payment.invoice
      if invoice.invoice_attachments.empty?
        add_message :error, "All payments must have an attached invoice"
        return
      end
    end

    # checking to make sure all the payments have an attached cost center
    self.bank_payment_request.payment_order.payments.each do |payment|
      invoice = payment.invoice
      if invoice.cost_center_id.blank?
        add_message :error, "All payments must have an associated cost center"
        return
      end
    end

    # checking to make sure there are no payments with 0 value
    self.bank_payment_request.payment_order.payments.each do |payment|
      if payment.amount_value <= 0
        add_message :error, "Payment amount cannot be 0"
        return
      end
    end
  end
end