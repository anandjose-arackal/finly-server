class Integrations::Tally::InvoiceVouchers < Integrations::Tally::Base
  attr_accessor :expenses, :invoices, :file_url

  def authorized_user_types
    []
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    unless user.company.tally_configuration.present? and
        user.company.tally_configuration.invoice_voucher_enabled and
        user.company.tally_configuration.invoice_voucher_configuration
      add_message :error, 'Tally integration has not been configured for your company'
      return
    end
    if params[:id].blank? and not params[:filtered]
      add_message :error, 'Invoice not found'
      return
    end

    authorized_roles = UserRole.ids_for(
        :admin, :finance_manager, :non_po_initiator, :invoice_auditor,
        :po_invoice_initiator, :po_invoice_reviewer, :po_invoice_auditor,
        :non_po_invoice_initiator, :non_po_invoice_reviewer,
        :non_po_invoice_auditor
    )
    user_roles = user.policy_user_roles.pluck(:user_role_id) + user.role_mapping.pluck(:user_role_id)

    unless (authorized_roles - user_roles).size < authorized_roles.size
      add_message :error, 'You are not authorized to perform this action'
      return
    end
  end

  def process
    {
        "company_name": "Metropolitan Stock Exchange of India Ltd. 17-18",
        "date": "{{invoice.date}}",
        "state": "{{invoice.billing_location.state.name}}",
        "voucher_type": "Purchase - {{invoice.billing_location.state.name}}",
        "reference": "{{invoice.invoice_number}}",
        "narration": "{{invoice.narration}}",
        "vendor": {
            "gstin": "{{invoice.vendor_location.gstin}}",
            "gl_name": "{{invoice.vendor.gl_name}}",
            "bill_allocations": [
                {
                    "name": "{{invoice.invoice_number}}",
                    "type": "New Ref",
                    "amount": "{{invoice.net_amount}}"
                }
            ]
        },
        "item": {
            "gl_name": "{{item.gl_code}}",
            "category_allocations": [
                {
                    "name": "Primary Cost Center",
                    "cost_center": "{{invoice.cost_center.gl_code}}",
                    "amount": "{{item.net_amount}}"
                },
                {
                    "name": "State Cost Center",
                    "cost_center": "{{invoice.billing_location.state.name}}",
                    "amount": "{{item.net_amount}}"
                }
            ],
            "gst_gl": {
                "sgst": "Input SGST Mumbai",
                "cgst": "Input CGST Mumbai",
                "igst": "Input IGST Mumbai"
            }
        },
        "tds_gl_name": "{{invoice.tds_slab.gl_code}}",
    }
    configuration = user.company.tally_configuration.invoice_voucher_configuration&.with_indifferent_access

    invoices_presenter = BankTransfer::InwardInvoices::Index.(user, params)
    unless invoices_presenter&.success?
      add_message :error, invoices_presenter.messages[:error]
      return
    end
    self.invoices = invoices_presenter.invoices
    if params[:filtered]
      self.invoices = self.invoices.processed
    else
      id = params[:id] || params[:invoice_id]
      id = id.split(',')
      self.invoices = self.invoices.with_id(id)
    end

    company_name = LiquidHelper.interpolate(configuration['company_name'], 'user' => user)
    generator = ::Tally::Generator.new(company_name: company_name)
    invoices.each do |invoice_obj|
      invoice = invoice_obj.to_liquid

      voucher = add_voucher generator, invoice, configuration
      add_vendor_ledgers voucher, invoice, configuration
      add_tds_ledgers voucher, invoice, configuration
      invoice.line_items.each do |item_obj|
        item = item_obj.to_liquid
        add_item_ledgers voucher, invoice, item, configuration
        add_item_gst_ledgers voucher, invoice, item, configuration
      end

      unless voucher.valid?
        add_message :error, voucher.errors.full_messages
        return
      end
    end
    file_data = generator.as_xml
    file = Paperclip::Tempfile.new(['export', '.xml'])
    open(file.path, 'wb') {|f| f.write file_data}
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 7.day)
    self.file_url = temp_file.file.url
  end

  def success
    Integrations::Tally::Base::FilePresenter.new(user, {file_url: self.file_url}, messages)
  end

  def add_voucher(generator, invoice, configuration)
    voucher_data = LiquidHelper.interpolate(configuration.slice('date', 'state', 'voucher_number', 'voucher_type', 'narration', 'reference'), "invoice" => invoice)
    vendor_data = LiquidHelper.interpolate(configuration['vendor'].slice('gl_name', 'gstin'), "invoice" => invoice)
    generator.add_voucher(voucher_data.merge(vendor_data))
  end

  def add_vendor_ledgers(voucher, invoice, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['vendor'], "invoice" => invoice)
    voucher.add ledger_data['gl_name'], invoice.net_amount, is_party_ledger: true, bill_allocations: ledger_data['bill_allocations']
  end

  def add_item_ledgers(voucher, invoice, item, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['item'].slice('gl_name', 'category_allocations'), "item" => item, "invoice" => invoice)
    value = item.billable_amount
    value = item.taxable_amount if value == 0
    voucher.add ledger_data['gl_name'], (-value), category_allocations: ledger_data['category_allocations']
  end

  def add_tds_ledgers(voucher, invoice, configuration)
    ledger_name = LiquidHelper.interpolate(configuration['tds_gl_name'], "invoice" => invoice)
    return if ledger_name.blank?

    voucher.add ledger_name, invoice.tds_amount, is_party_ledger: false
  end

  def add_item_gst_ledgers(voucher, invoice, item, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['item']['gst_gl'], "item" => item, "invoice" => invoice)

    voucher.add ledger_data['cgst'], (-item.cgst_amount) if item.cgst_amount.present?
    voucher.add ledger_data['sgst'], (-item.sgst_amount) if item.sgst_amount.present?
    voucher.add ledger_data['igst'], (-item.igst_amount) if item.igst_amount.present?
  end


end