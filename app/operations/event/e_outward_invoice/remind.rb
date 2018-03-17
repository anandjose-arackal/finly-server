class Event::EOutwardInvoice::Remind < Event::EOutwardInvoice::Base
  attr_accessor :target_users

  def pre_process
  end

  def validate
    if outward_invoice.incomplete?
      add_message :error, "Incompete invoice cannot be sent to customers."
    end
  end

  def process
    InvoiceMailer.delay.auto_remind_customer(outward_invoice)
  end

end
