class ProcurementMailer < ApplicationMailer
  # for explicitly sending to vendor or other people
  def send_mail(presenter)
    @data = presenter
    @document = presenter.document
    @purchase_order = presenter.document
    @user = presenter.user
    @company = @user.company

    @result = Procurements::PurchaseOrders::Show.(@data.user, {purchase_order_id: @data.document.id })
    attachments["purchase_order-#{@document.po_number}.pdf"] = WickedPdf.new.pdf_from_string(
         render_to_string(
             pdf: "purchase-order-#{@document.po_number}",
             encoding: 'UTF-8',
             template: "export/purchase_order",
             layout: "pdf/paginated_bootstrap.html.erb",
             footer: { html: { template: 'layouts/partials/_po_footer.html.erb' }},
             print_media_type: true
         )
    )
    if @data.attachments.present? && @data.attachments.is_a?(Array)
      @data.attachments.each do |attachment|
        url = attachment.file.path
        attachments[attachment.file_file_name] = {
            content: open(url).read
        }
      end
    end

    mail from: "#{@user.company.name} <noreply@finly.io>", :reply_to => "#{@user.email}", to: @data.email_to,
         bcc: @data.email_bcc_to, subject: @data.email_subject, template_name: 'mail_procurement'
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
         render_to_string(
             pdf: "purchase-order-#{@data.purchase_order.po_number}",
             encoding: 'UTF-8',
             template: "export/purchase_order",
             layout: "pdf/paginated_bootstrap.html.erb",
             # layout: "pdf.html.erb",
             footer: { html: { template: 'layouts/partials/_po_footer.html.erb' }},
             print_media_type: true
         )
      )
      mail to: presenter.to, subject: presenter.subject, template_name: 'template'
      # mail to: 'abinash.b2@gmail.com', subject: presenter.subject, template_name: 'template'
    end
  end


  # Automatically sent for invoice actions
  def send_invoice_mail(presenter)
    return unless presenter.validate
    @data = presenter
    @company = @data.user.company
    #### variables required for the attachment pdf #########
    @result = Procurements::Invoices::Show.(@data.user, {invoice_id: @data.invoice.id })
    if @result.success?
      @invoice = @data.invoice
      @curr_user = @data.user
      attachments["invoice-#{@data.invoice.invoice_number}.pdf"] = WickedPdf.new.pdf_from_string(
         render_to_string(
             pdf: "invoice-#{@data.invoice.invoice_number}",
             encoding: 'UTF-8',
             template: "export/inward_invoice",
             layout: "pdf/paginated_bootstrap.html.erb",
             # layout: "pdf.html.erb",
             footer: { html: { template: 'layouts/partials/_po_footer.html.erb' }},
             print_media_type: true
         )
      )
      ########################################################
      # attachments["invoice-#{@data.invoice.invoice_number}.pdf"] = WickedPdf.new.pdf_from_string(
      #    render_to_string(pdf: "invoice-#{@data.invoice.invoice_number}", template: "export/inward_invoice", layout: "pdf.html.erb", print_media_type: true)
      # )
      mail to: presenter.to, subject: presenter.subject, template_name: 'template_invoice'
    end
  end

  def purchase_order_bulk_approval(presenter)
    @data = presenter
    if presenter.success?
      mail to: presenter.to, bcc: 'kumar.abinash@finly.io', subject: presenter.subject, template_name: 'template_bulk_approval'
    end
  end

  def invoice_bulk_approval(presenter)
    @data = presenter
    if presenter.success?
      mail to: presenter.to, bcc: 'kumar.abinash@finly.io', subject: presenter.subject, template_name: 'bulk_approval_invoices'
    end
  end

  def invoices_bulk_import(presenter)
    @data = presenter
    if presenter.success?
      mail to: presenter.to, bcc: 'kumar.abinash@finly.io', subject: presenter.subject, template_name: 'template_bulk_import_invoices'
    end
  end
end