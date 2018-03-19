class InvoiceMailer < ApplicationMailer

  def send_to_customer(invoice, options)
    @invoice = invoice
    @options = options
    ###################### adding the generated invoice as an attachment #####################
    attachments["invoice-#{@invoice.invoice_number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(pdf: "invoice-#{@invoice.invoice_number}", template: "invoicing/outward_invoices/download", layout: "pdf.html.erb", print_media_type: true)
    )

    for attachment in options[:attachments]
      url = "#{Rails.root}/public" + attachment.attachment.url('original', timestamp: false)
      attachments[attachment.attachment_file_name] = {
          content: open(url).read
      }
    end

    # attachments["report_#{Date.today.iso8601}.pdf"] = {
    #     mime_type: 'application/pdf',
    #     content: open(@report.pdf.expiring_url).read
    # }
    # ###########################################

    mail to: options[:email_to], bcc: options[:email_bcc], subject: options[:email_subject], template_name: 'send_to_customer'
  end

  def auto_remind_customer(invoice)
    @invoice = invoice
    @options = {
      email_subject: "Payment due for invoice - #{@invoice.invoice_number}",
      email_body: "This is an system generated mail to reminder you, your payment for invoice with number #{@invoice.invoice_number} is due on #{@invoice.due_date} Please ignore if already paid."
    }

    ###################### adding the generated invoice as an attachment #####################
    attachments["invoice-#{@invoice.invoice_number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(pdf: "invoice-#{@invoice.invoice_number}", template: "invoicing/outward_invoices/download", layout: "pdf.html.erb", print_media_type: true)
    )
    ###########################################
    mail to: @invoice.email, subject: @options[:email_subject], template_name: 'send_to_customer'
  end

end