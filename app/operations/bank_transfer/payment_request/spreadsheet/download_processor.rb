class BankTransfer::PaymentRequest::Spreadsheet::DownloadProcessor < BackgroundOperation
  sidekiq_options queue: :payments

  attr_accessor :view_role, :bank_payment_requests,
                :headers, :field_configurations, :include_attachments, :download_url, :file_name, :sheets

  def pre_validate
    if params&.dig(:bank_payment_request_id).blank?
      add_message :error, 'Nothing to export'
      return
    end
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.include_attachments = !!params[:include_attachments]
    self.bank_payment_requests = BankPaymentRequest.with_id(params&.dig(:bank_payment_request_id)).include_for_data_retrieval
  end

  def validate
    if self.bank_payment_requests.blank?
      add_message :error, 'No payment orders passed'
      return
    end
  end

  def process
    headers = retrieve_headers
    content = retrieve_data
    sheets = [{
                  item_headers: headers,
                  item_contents: content,
                  name: "Payment Tickets"
              }]
    exported_xls = Exporter.new(user, {xlsx: {headers: headers, contents: content, sheets: sheets}}, messages).xlsx_exporter.export_file_path
    exportable_file = exported_xls
    self.file_name = 'export.xls'
    if include_attachments
      files = []
      files << {name: 'export.xls', file_contents: exported_xls}
      bank_payment_requests.include_attachments.find_each(batch_size: 1000) do |bpr|
        file_name_prefix = "#{bpr.id}"
        count = 1
        bpr.payment_order&.payment_order_attachments&.each do |attachment|
          file = attachment.attached_file
          next if file.blank?
          name_splits = attachment.attached_file_file_name&.split('.')
          extension = (name_splits.present? and name_splits.size > 1) ? ".#{name_splits&.last}" : ''
          files << {name: "#{file_name_prefix}_#{count}#{extension}", url: file.url}
          count += 1
        end
        bpr.payment_order&.payments&.each do |payment|
          invoice = payment.invoice
          count = 1
          invoice&.invoice_attachments&.each do |attachment|
            file = attachment.attached_file
            next if file.blank?
            name_splits = attachment.attached_file_file_name&.split('.')
            extension = (name_splits.present? and name_splits.size > 1) ? ".#{name_splits&.last}" : ''
            files << {name: "#{file_name_prefix}_payment_#{count}#{extension}", url: file.url}
            count += 1
          end
        end
      end
      exportable_file = Exporter::AsZip.new(user, {files: files}, messages).generate_zip
      self.file_name = 'export.zip'
      exportable_file = create_temporary_link(exportable_file)
    end
    self.download_url = exportable_file
  end

  def post_process
    unless self.download_url.present?
      add_message :error, 'Error creating download link'
      return
    end
    Event::EPaymentOrderDownload::Create.(user, user: user, download_url: self.download_url)
  end

  def success
  end

  # def success
  #   headers = retrieve_headers
  #   content = retrieve_data
  #   self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  # end

  protected
  def create_temporary_link(file)
    return nil if file.nil?
    temp_file = File.open(self.file_name, 'wb')
    temp_file.write file
    temp_file.rewind
    # temp_file
    t = TemporaryFile.create(file: temp_file, expires_on: (DateTime.now + 1.day))
    File.delete(temp_file.path)
    unless t.valid?
      add_message :error, t.errors.full_messages
      return
    end
    t.file.url
  end

  def retrieve_headers
    headers = ["Payment Order ID",
               "Payment Order Name",
               "Payment ID",
               "Beneficiary Name",
               "Beneficiary Code",
               "Beneficiary Account Name",
               "Beneficiary Account Number",
               "Beneficiary IFSC",
               "Payment Mode",
               "Initiated By",
               "Initiator Email",
               "Payment Order Status",
               "Payment Order Schedule Date",
               "Payment Order Submitted Date",
               "Payment Order Processed Date",
               "Awaiting Action From",
               "Policy",
               "PO Number",
               "Invoice Number",
               "Invoice Due Date",
               "Invoice Date",
               "Invoice ID"]
    headers += retrieve_custom_field_headers
    headers += ["Original Amount",
                "Advance Amount",
                "Discount",
                "Tax",
                "TDS",
                "Net Payable Amount",
                "Bank Reference Number",
                "Note",
                "Payment Status",
                "Error Message"]
  end

  def retrieve_data
    return [] if bank_payment_requests.empty?
    content = []
    ActiveRecord::Base.uncached do
    bank_payment_requests.include_for_data_retrieval.find_each(batch_size: 1000) do |pr|
      po = pr.payment_order
      po.payments.each do |payment|
        reviewer_names = payment.payment_order.bank_payment_request.get_reviewers&.map(&:name)&.join(", ")
        purchase_order = (payment.parent_type == 'PurchaseOrder' ? payment.parent : nil)
        vendor = (payment.receiving_user_type == 'YesBankVendor' ? payment.receiving_user : nil)
        payment_details = [
            pr.id,
            pr.name,
            payment.id,
            "#{payment.receiving_account&.account_owner&.name}",
            vendor.present? ? vendor.vendor_id : '',
            "#{payment.receiving_account&.name}",
            "'#{payment.receiving_account&.account_number}",
            payment.receiving_account&.ifsc,
            payment.payment_mode&.upcase,
            payment.initiating_user.name,
            payment.initiating_user.email,
            payment.payment_order.bank_payment_request.status&.name&.humanize,
            payment.payment_order.scheduled_at&.strftime("%d-%b-%Y"),
            payment.payment_order.bank_payment_request.submitted_at&.strftime("%d-%b-%Y"),
            payment.payment_order.processed_at&.strftime("%d-%b-%Y"),
            # payment.payment_order.bank_payment_request.controlling_user&.name,
            reviewer_names,
            pr.policy&.name,
            purchase_order.present? ? purchase_order&.po_number: '',
            payment.invoice&.invoice_number,
            payment.invoice&.due_date&.strftime("%d-%b-%Y"),
            payment.invoice&.date&.strftime("%d-%b-%Y"),
            payment.invoice&.invoice_id
        ]
        payment_details += retrieve_custom_fields(payment)
        case payment.parent_type
        when 'PurchaseOrder'
          po = payment.parent
          payment_details += [
              precision_value(po&.total_after_tax&.value),
              precision_value(po&.advance_amount&.value),
              0.0,
              0.0,
              (po&.advance_tds_slab&.tds || 0.0),
              (payment.amount&.value || 0.0)
          ]
        when 'BeneficiaryPayment'
          bp = payment.parent
          payment_details += [
              (bp&.original_amount&.value || 0.0),
              (bp&.advance_amount&.value || 0.0),
              0.0,
              (bp&.tax_amount&.value || 0),
              (bp&.tds_amount&.value || 0),
              (payment.amount&.value || 0)
          ]
        else
          payment_details += [
              original_amount_invoice(payment),
              (payment.invoice&.advance_amount&.value || 0.0),
              (payment.invoice&.discount_amount&.value || 0.0),
              (payment.invoice&.tax || 0.0),
              (payment.invoice&.tds || 0.0),
              (payment.amount&.value || 0.0)
          ]
        end
        payment_details += [
            (payment.utr),
            payment.note,
            payment.payment_status&.name&.humanize,
            (payment.system_messages.pluck(:content)&.to_sentence)
        ]
        content << payment_details
      end
    end
    end
    content
  end

  def retrieve_custom_field_headers
    self.field_configurations = FieldConfiguration.with_company(user.company_id).non_deleted
    self.field_configurations.pluck(:field_name)
  end

  def retrieve_custom_fields(payment)
    values = []
    custom_fields = payment.invoice&.custom_fields
    self.field_configurations.each do |fc|
      if custom_fields.present?
        values << custom_fields.with_field_configuration_ids(fc.id).first&.string_value
      else
        values << ""
      end
    end
    values
  end

  def original_amount_invoice(payment)
    original_amount = 0.0
    if payment.invoice.present?
      invoice = payment.invoice
      if invoice&.invoice_items.present?
        original_amount = (invoice.amount&.value || 0.0)
      else
        original_amount = (invoice&.original_amount&.value || 0.0)
      end
    else
      original_amount = (payment&.amount&.value || 0.0)
    end
    original_amount
  end

  def tds_amount(payment)
    tds_amount = 0.0
    if payment.parent_type == 'PurchaseOrder'
      tds_amount = (payment.parent.advance_tds_amount&.value || 0.0)
    else
      tds_amount = (payment.invoice&.tds_amount&.value || 0.0)
    end
    tds_amount
  end
end