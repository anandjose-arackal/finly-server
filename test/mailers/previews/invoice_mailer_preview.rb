class InvoiceMailerPreview < ActionMailer::Preview

  # Preview all emails at http://localhost:3001/rails/mailers/invoice_mailer

  def send_to_customer
    @invoice = OutwardInvoice.find 50
    InvoiceMailer.send_to_customer(@invoice)
  end
end