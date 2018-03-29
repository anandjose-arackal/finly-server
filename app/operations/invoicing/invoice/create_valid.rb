# will have to structure this more neatly in the future

class Invoicing::Invoice::CreateValid < Invoicing::Invoice::Base

  attr_accessor :invoice

  def process
    op = Invoicing::Invoice::Create.(user, params)
    if op.success?
      params[:outward_invoice_id] = op.invoice.id
      # adding the invoice number of the created invoice here for saving
      save_op = Invoicing::Invoice::SaveInvoice.(user, params)
      if save_op.success?
        self.invoice = save_op.invoice
      else
        add_message :error, save_op.messages[:error]
      end
    else
      add_message :error, op.messages[:error]
      return
    end
  end

  def success
    params[:invoice] = self.invoice
    Invoicing::Invoice::Base::InvoicePresenter.new(user, params, messages)
  end

  def post_process
    # sending mailer to the owner of the invoice
    InvoiceMailer.delay.send_to_customer(invoice)
  end

end