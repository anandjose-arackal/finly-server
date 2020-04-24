class ExportManager::Master::Invoices::TallyExport < ExportManager::Builders::Tally

  label 'Tally Export'
  description 'Tally Export (Invoice)'
  handle :tally_invoices
  screen 'invoices.index'
  system :vp
  tally_config_key :invoice_voucher_configuration

  def input
    invoices = Resolver::Router.dispatch('invoices.default', params: params.merge(filter: true, paginate: false), current_user: user)
    invoices.scope_all_except_voided
  end

  def generate_voucher(generator, invoice)
    voucher_data = LiquidHelper.interpolate(configuration.slice('date', 'state', 'voucher_number', 'voucher_type', 'narration', 'reference'), "invoice" => invoice)
    vendor_data = LiquidHelper.interpolate(configuration['vendor'].slice('gl_name', 'gstin'), "invoice" => invoice)
    generator.add_voucher(voucher_data.merge(vendor_data))
  end

  def add_ledgers(voucher, invoice)
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