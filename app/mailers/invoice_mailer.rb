class InvoiceMailer < ApplicationMailer

  def send_to_customer(invoice)
    @invoice = invoice
    ###################### adding the generated invoice as an attachment #####################
    # todo
    ###########################################
    mail to: @invoice.email, subject: "Invoice for #{@invoice.customer.name} - #{@invoice.invoice_number}", template_name: 'send_to_customer'
  end

end