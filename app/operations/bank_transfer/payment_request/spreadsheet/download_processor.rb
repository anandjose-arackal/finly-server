class BankTransfer::PaymentRequest::Spreadsheet::DownloadProcessor < BackgroundOperation

  attr_accessor :view_role, :bank_payment_requests,
                :headers, :field_configurations, :include_attachments, :download_url, :file_name

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
    self.bank_payment_requests = BankPaymentRequest.with_id(params&.dig(:bank_payment_request_id))
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
    exported_xls = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages).spreadsheet_exporter.generate_xls
    exportable_file = exported_xls
    self.file_name = 'export.xls'
    if include_attachments
      files = []
      files << {name: 'export.xls', file_contents: exported_xls}
      bank_payment_requests.include_attachments.each do |bpr|
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
    end
    self.download_url = create_temporary_link(exportable_file)
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
    temp_file = File.open(self.file_name, 'w')
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
               "Beneficiary Name",
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
               "Invoice Number",
               "Invoice Due Date",
               "Invoice Date"]
    headers += retrieve_custom_field_headers
    headers += ["Invoice Amount",
                "Discount",
                "Tax",
                "TDS",
                "Advance",
                "Net Amount",
                "Bank Reference Number",
                "Note",
                "Payment Status",
                "Error Message"]
  end

  def retrieve_data
    return [] if bank_payment_requests.empty?
    content = []
    bank_payment_requests.include_for_data_retrieval.each do |pr|
      po = pr.payment_order
      po.payments.each do |payment|
        payment_details = [
            pr.id,
            pr.name,
            "#{payment.receiving_account&.account_owner&.name}",
            "#{payment.receiving_account&.name}",
            payment.receiving_account&.account_number,
            payment.receiving_account&.ifsc,
            payment.payment_mode&.upcase,
            payment.initiating_user.name,
            payment.initiating_user.email,
            payment.payment_order.bank_payment_request.status&.name&.humanize,
            payment.payment_order.scheduled_at&.strftime("%d-%m-%Y"),
            payment.payment_order.bank_payment_request.submitted_at&.strftime("%d-%m-%Y"),
            payment.payment_order.processed_at&.strftime("%d-%m-%Y"),
            payment.payment_order.bank_payment_request.controlling_user&.name,
            payment.invoice&.invoice_number,
            payment.invoice&.due_date&.strftime("%d-%m-%Y"),
            payment.invoice&.date&.strftime("%d-%m-%Y")
        ]
        payment_details += retrieve_custom_fields(payment)
        payment_details += [
            (payment.invoice&.amount&.value || 0),
            (payment.invoice&.discount_amount&.value || 0),
            (payment.invoice&.tax_amount&.value || 0),
            (payment.invoice&.tds_amount&.value || 0),
            (payment.invoice&.advance_amount&.value || 0),
            (payment.amount&.value || 0),
            (payment.reference_resource&.bank_reference_number),
            payment.note,
            payment.payment_status&.name&.humanize,
            (payment.system_messages.pluck(:content)&.to_sentence)
        ]
        content << payment_details
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
end