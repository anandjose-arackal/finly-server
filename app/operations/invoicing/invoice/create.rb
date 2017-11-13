class Invoicing::Invoice::Create < Invoicing::Invoice::Base

  attr_accessor :invoice_params, :invoice

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    id = params[:id] || params[:payment_id]
    self.payment = Payment.find_by(id: id)
  end

  def validate

  end

  def process
    if self.payment.present?
      self.invoice = self.payment.build_invoice(invoice_params)
      unless self.invoice.save
        add_message :error, self.invoice.errors.full_messages
        return
      end
    else
      self.invoice = Invoice.new(invoice_params)
      unless self.invoice.save
        add_message :error, self.invoice.errors.full_messages
        return
      end
    end
  end

end