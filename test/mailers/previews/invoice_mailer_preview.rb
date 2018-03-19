class InvoiceMailerPreview < ActionMailer::Preview

  # Preview all emails at http://localhost:3001/rails/mailers/invoice_mailer

  def send_to_customer
    @invoice = OutwardInvoice.find 123
    @options = {
        attachments: @invoice.attachments,
        email_subject: "Payment due for invoice - #{@invoice.invoice_number}",
        email_body: "This is an system generated message to reminder you, your payment for invoice with number #{@invoice.invoice_number} is due on #{@invoice.due_date}. Please ignore if already paid."
    }

    InvoiceMailer.send_to_customer(@invoice, @options)
  end
end