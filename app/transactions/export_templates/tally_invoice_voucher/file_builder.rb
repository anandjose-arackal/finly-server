class ExportTemplates::TallyInvoiceVoucher::FileBuilder < ExportTemplates::Helpers::BaseFileBuilder

  def build_file(options, data:, template:, configuration:, user:, **)
    invoices = data #options['data']
    # template = options['template']
    # configuration = options['configuration']
    company_name = LiquidHelper.interpolate(configuration['company_name'], 'user' => user)
    generator = ::Tally::Generator.new(company_name: company_name)
    invoices.each do |invoice_obj|
      invoice = invoice_obj.to_liquid

      voucher = add_voucher generator, invoice, configuration
      add_vendor_ledgers voucher, invoice, configuration
      invoice.line_items.each do |item_obj|
        item = item_obj.to_liquid
        add_item_ledgers voucher, invoice, item, configuration
        add_item_gst_ledgers voucher, invoice, item, configuration
      end

      return on_error(options, :base, voucher.errors.full_messages) unless voucher.valid?
    end

    set_file_data options, generator.as_xml
    true
  end

  def add_voucher(generator, invoice, configuration)
    voucher_data = LiquidHelper.interpolate(configuration.slice('date', 'state', 'voucher_type', 'narration', 'reference'), "invoice" => invoice)
    vendor_data = LiquidHelper.interpolate(configuration['vendor'].slice('gl_name', 'gstin'), "invoice" => invoice)
    generator.add_voucher(voucher_data.merge(vendor_data))
  end

  def add_vendor_ledgers(voucher, invoice, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['vendor'], "invoice" => invoice)
    voucher.add ledger_data['gl_name'], invoice.net_amount, is_party_ledger: true, bill_allocations: ledger_data['bill_allocations']
  end

  def add_item_ledgers(voucher, invoice, item, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['item'].slice(:gl_name, :category_allocations), "item" => item, "invoice" => invoice)
    voucher.add ledger_data['gl_name'], (-item.taxable_amount), category_allocations: ledger_data['category_allocations']
  end

  def add_item_gst_ledgers(voucher, invoice, item, configuration)
    ledger_data = LiquidHelper.interpolate(configuration['item']['gst_gl'], "item" => item, "invoice" => invoice)
    if item.cgst_amount.present?
      voucher.add ledger_data['cgst'], (-item.cgst_amount)
    end
    if item.sgst_amount.present?
      voucher.add ledger_data['sgst'], (-item.sgst_amount)
    end
    if item.igst_amount.present?
      voucher.add ledger_data['igst'], (-item.igst_amount)
    end
  end

end