class ProcurementMailer < ApplicationMailer
  def send_purchase_order(purchase_order, options)
    @purchase_order = purchase_order
    @options = options

    #todo create download file
    # attachments["purchase-order-#{@purchase_order.po_number}.pdf"] = WickedPdf.new.pdf_from_string(
    #     render_to_string(pdf: "purchase-order-#{@purchase_order.po_number}.pdf", template: "procure/purchase_orders/download", layout: 'pdf.html.erb', print_media_type: true,
    #                      margin: {:bottom => 5},
    #                      footer: {html: {template: "invoice_mailer/invoice_footer.html.erb"}}
    #     )
    # )

    mail from: "#{@purchase_order.company.name} <noreply@finly.io>", :reply_to => "#{@purchase_order.user.email}", to: @options[:email_to],
         bcc: @options[:email_bcc], subject: @options[:email_subject], template_name: 'mail_purchase_order'

  end


  def send_inward_document

  end
end