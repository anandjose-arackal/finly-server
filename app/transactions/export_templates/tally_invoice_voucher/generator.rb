class ExportTemplates::TallyInvoiceVoucher::Generator < ExportTemplates::BaseGenerator

  def process(invoices)
    company_name = LiquidHelper.interpolate(configuration['company_name'], 'user' => user)
    generator = ::Tally::Generator.new(company_name: company_name)
    invoices.each do |invoice_obj|
      invoice = invoice_obj.to_liquid

      voucher = add_voucher generator, invoice
      add_vendor_ledgers voucher, invoice
      invoice.line_items.each do |item_obj|
        item = item_obj.to_liquid
        add_item_ledgers voucher, invoice, item
        add_item_gst_ledgers voucher, invoice, item
      end

      unless voucher.valid?
        add_message :error, voucher.errors.full_messages
        return
      end
    end

    file = save_to_temp_file "tally_export.xml", generator.as_xml
    save_to_file_manager file
  end

  def add_voucher(generator, invoice)
    voucher_data = LiquidHelper.interpolate(configuration.slice('date', 'state', 'voucher_type', 'narration', 'reference'), "invoice" => invoice)
    vendor_data = LiquidHelper.interpolate(configuration['vendor'].slice('gl_name', 'gstin'), "invoice" => invoice)
    generator.add_voucher(voucher_data.merge(vendor_data))
  end

  def add_vendor_ledgers(voucher, invoice)
    ledger_data = LiquidHelper.interpolate(configuration['vendor'], "invoice" => invoice)
    voucher.add ledger_data['gl_name'], invoice.net_amount, is_party_ledger: true, bill_allocations: ledger_data['bill_allocations']
  end

  def add_item_ledgers(voucher, invoice, item)
    ledger_data = LiquidHelper.interpolate(configuration['item'].slice(:gl_name, :category_allocations), "item" => item, "invoice" => invoice)
    voucher.add ledger_data['gl_name'], (-item.taxable_amount), category_allocations: ledger_data['category_allocations']
  end

  def add_item_gst_ledgers(voucher, invoice, item)
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