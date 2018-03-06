class InvoiceMailer < ApplicationMailer

  def send_to_customer(invoice)
    @invoice = invoice
    ###################### adding the generated invoice as an attachment #####################
    attachments["invoice-#{@invoice.invoice_number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(pdf: "invoice-#{@invoice.invoice_number}", template: "invoicing/outward_invoices/download", layout: "pdf.html.erb", print_media_type: true)
    )
    ###########################################
    mail to: @invoice.email, subject: "Invoice for #{@invoice.customer.name} - #{@invoice.invoice_number}", template_name: 'send_to_customer'
  end

end