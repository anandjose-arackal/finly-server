class ProcurementMailer < ApplicationMailer
  def send_purchase_order(purchase_order, options)
    # @purchase_order = purchase_order
    # @options = options
    #
    # #todo create download file
    # # attachments["purchase-order-#{@purchase_order.po_number}.pdf"] = WickedPdf.new.pdf_from_string(
    # #     render_to_string(pdf: "purchase-order-#{@purchase_order.po_number}.pdf", template: "procure/purchase_orders/download", layout: 'pdf.html.erb', print_media_type: true,
    # #                      margin: {:bottom => 5},
    # #                      footer: {html: {template: "invoice_mailer/invoice_footer.html.erb"}}
    # #     )
    # # )
    #
    # mail from: "#{@purchase_order.company.name} <noreply@finly.io>", :reply_to => "#{@purchase_order.user.email}", to: @options[:email_to],
    #      bcc: @options[:email_bcc], subject: @options[:email_subject], template_name: 'mail_purchase_order'
    @result = Procurements::PurchaseOrders::Show.(@data.user, {purchase_order_id: @data.purchase_order.id })
    if @result.success?
      @purchase_order = @data.purchase_order
      @curr_user = @data.user
      ########################################################
      attachments["purchase_order-#{@data.purchase_order.po_number}.pdf"] = WickedPdf.new.pdf_from_string(
         render_to_string(pdf: "report-#{@data.purchase_order.po_number}", template: "export/purchase_order", layout: "pdf.html.erb", print_media_type: true)
      )
      mail to: presenter.to, subject: presenter.subject, template_name: 'mail_procurement'
    end

  end

  # for explicitly sending to vendor or other people
  def send_mail(document, options, user)
    @document = document
    @options = options
    @user = user

    mail from: "#{@user.company.name} <noreply@finly.io>", :reply_to => "#{@user.email}", to: @options[:email_to],
         bcc: @options[:email_bcc_to], subject: @options[:email_subject], template_name: 'mail_procurement'
  end

  # Automatically sent for purchase order actions
  def send_purchase_order_mail(presenter)
    return unless presenter.validate
    @data = presenter
    @company = @data.user.company
    #### variables required for the attachment pdf #########
    @result = Procurements::PurchaseOrders::Show.(@data.user, {purchase_order_id: @data.purchase_order.id })
    if @result.success?
      @purchase_order = @data.purchase_order
      @curr_user = @data.user
      ########################################################
      attachments["purchase_order-#{@data.purchase_order.po_number}.pdf"] = WickedPdf.new.pdf_from_string(
         render_to_string(pdf: "report-#{@data.purchase_order.po_number}", template: "export/purchase_order", layout: "pdf.html.erb", print_media_type: true)
      )
      mail to: presenter.to, subject: presenter.subject, template_name: 'template'
    end
  end
end