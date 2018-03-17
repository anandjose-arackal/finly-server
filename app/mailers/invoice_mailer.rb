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

    ###################### adding the generated invoice as an attachment #####################
    attachments["invoice-#{@invoice.invoice_number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(pdf: "invoice-#{@invoice.invoice_number}", template: "invoicing/outward_invoices/download", layout: "pdf.html.erb", print_media_type: true)
    )
    ###########################################
    mail to: @invoice.email, subject: "Payment due for invoice - #{@invoice.invoice_number}", template_name: 'auto_remind_customer'
  end

  def remind_customer(invoice, options)
    @invoice = invoice
    @data = options

    ###################### adding the generated invoice as an attachment #####################
    attachments["invoice-#{@invoice.invoice_number}.pdf"] = WickedPdf.new.pdf_from_string(
        render_to_string(pdf: "invoice-#{@invoice.invoice_number}", template: "invoicing/outward_invoices/download", layout: "pdf.html.erb", print_media_type: true)
    )
    ###########################################
    mail to: @invoice.email, subject: "#{data.subject}", template_name: 'auto_remind_customer'
  end

end