class Personalizer::Adapters::Company234::ExportTemplates234::TallyInvoicesTemplate < ExportManager::Builders::Spreadsheet

  label 'Tally Invoices Export'
  description 'Tally Invoices Export'
  configurable false
  handle :tally_invoices_export_sme
  screen 'invoices.index'
  system :vp
  scope 'development', 2, 'L&C Ltd.'
  scope "staging", 2, 'L&C Ltd.'
  scope "production", 234, 'SMEcorner'
  validate :fetch_invoices

  attr_accessor :categories

  def fetch_invoices
    invoices_presenter = BankTransfer::InwardInvoices::Index.(user, params)

    unless invoices_presenter.success?
      add_message :error, invoices_presenter.messages[:error]
      return
    end
    invoices_presenter
  end

  def input
    invoices_presenter = fetch_invoices

    return if has_errors?

    invoices = invoices_presenter.invoices.where(invoice_status_id: Invoice.finance_associated_status_ids)
  end

  def generate_rows
    generate_headers
    sl_no = 1
    data.find_each do |inv|
      total_credit_entries(inv).map {|entry| rows << entry}
      line_item_entries(inv).map {|entry| rows << entry}

      if with_tax(inv)
        gst_item_entries(inv).map {|entry| rows << entry}
      end

      if with_tds(inv)
        tds_item_entries(inv).map {|entry| rows << entry}
      end
      sl_no += 1
      progress_update sl_no
    end
  end

  def total_credit_entries(invoice)
    entries = []
    row = ExportManager::Builders::Spreadsheet::Row.new(record: invoice, header: header)
    {
        'Date': {value: invoice.submitted_at, type: 'date'},
        'Voucher No': invoice.invoice_number,
        'Invoice  Date': {value: invoice.date, type: 'date'},
        'New Ref': invoice.invoice_number,
        'Ledger Name': invoice.vendor&.display_name,
        'CR Amt': ((invoice.taxable_amount&.value&.to_f || 0) + invoice.tax_amount&.value&.to_f) - invoice.tds_amount&.value&.to_f,
        'Cost Centre': invoice.cost_center&.name,
        'Narration': "Being amount to be paid against invoice no: #{invoice.invoice_number} dated: #{invoice.created_at} towards #{invoice.narration}",
        'Voucher Type': 'Purchase',
    }.each do |k, v|
      row.add k, v
    end
    entries << row
  end

  def line_item_entries(invoice)
    entries = []
    invoice.items.each do |item|
      row = ExportManager::Builders::Spreadsheet::Row.new(record: item, header: header)
      {
          'Date': {value: invoice.submitted_at, type: 'date'},
          'Voucher No': invoice.invoice_number,
          'Invoice  Date': {value: invoice.date, type: 'date'},
          'New Ref': invoice.invoice_number,
          'Ledger Name': item.category&.name,
          'DR Amt': item.taxable_amount&.value,
          'Cost Centre': invoice.cost_center&.name,
          'Narration': "Being amount to be paid against invoice no: #{invoice.invoice_number} dated: #{invoice.created_at.strftime("%d-%m-%Y")} towards #{invoice.narration}",
          'Voucher Type': 'Purchase',
      }.each do |k, v|
        row.add k, v
      end
      entries << row
    end
    entries
  end

  def gst_item_entries(invoice)
    entries = []
    tax_types = [:igst, :sgst, :cgst]
    tax_types.each do |tax_type|
      invoice.items.each do |item|
        next if item.send(tax_type).to_f <= 0
        row = ExportManager::Builders::Spreadsheet::Row.new(record: item, header: header)
        {
            'Date': {value: invoice.submitted_at, type: 'date'},
            'Voucher No': invoice.invoice_number,
            'Invoice  Date': {value: invoice.date, type: 'date'},
            'New Ref': invoice.invoice_number,
            'Ledger Name': get_tax_ledger(tax_type, item),
            'DR Amt': item.send(tax_type),
            'Cost Centre': invoice.cost_center&.name,
            'Narration': "Being amount to be paid against invoice no: #{invoice.invoice_number} dated: #{invoice.created_at.strftime("%d-%m-%Y")} towards #{invoice.narration}",
            'Voucher Type': 'Purchase',
        }.each do |k, v|
          row.add k, v
        end
        entries << row
      end
    end
    entries
  end

  def tds_item_entries(invoice)
    entries = []
    row = ExportManager::Builders::Spreadsheet::Row.new(record: invoice, header: header)
    {
        'Date': {value: invoice.submitted_at, type: 'date'},
        'Voucher No': invoice.invoice_number,
        'Invoice  Date': {value: invoice.date, type: 'date'},
        'New Ref': invoice.invoice_number,
        'Ledger Name': get_tds_ledger_name(invoice),
        'CR Amt': invoice.tds_amount&.value&.to_f,
        'Cost Centre': invoice.cost_center&.name,
        'Narration': "Being amount to be paid against invoice no: #{invoice.invoice_number} dated: #{invoice.created_at.strftime("%d-%m-%Y")} towards #{invoice.narration}",
        'Voucher Type': 'Purchase',
    }.each do |k, v|
      row.add k, v
    end
    entries << row
  end

  def generate_headers
    [
        'Date',
        'Voucher No',
        'Invoice  Date',
        'Advance',
        'Against Ref',
        'New Ref',
        'On Account',
        'Inst. No.',
        'Bill Ref Amt',
        'Ledger Name',
        'DR Amt',
        'CR Amt',
        'Cost Centre',
        'Narration',
        'Voucher Type'
    ].each do |k|
      header.add k
    end
  end

  def with_tax(invoice)
    return false if invoice.tax_amount.nil?
    invoice.tax_amount&.value > 0 ? true : false
  end

  def with_tds(invoice)
    return false if invoice.tds.nil?
    invoice.tds > 0 ? true : false
  end

  def get_tds_ledger_name(invoice)
    "Tds #{invoice.tds_slab&.name&.split("194")&.first}"
  end

  def get_tax_ledger(tax_type, item)
    if tax_type == :igst
      "IGST #{item.tax&.to_s&.sub(/\.?0+$/, '')}% Input Credit"
    else
      ledger = "#{tax_type.to_s.upcase} #{(item.tax / 2)&.to_s&.sub(/\.?0+$/, '')}%"
      # state will be blank if vendor not have gstin registration and system not mapped
      state = state_code(item).to_s
      state += " - " if state.present?
      ledger += state
    end
  end

  def state_code(item)
    return "" if item.parent&.gstin_location&.state.nil?
    item.parent&.gstin_location&.state[0..1] rescue ""
  end

  def total_tax_value(item)
    value = 0
    value += item.cgst unless item.cgst.nil?
    value += item.sgst unless item.sgst.nil?
    value += item.igst unless item.igst.nil?
    value
  end

end