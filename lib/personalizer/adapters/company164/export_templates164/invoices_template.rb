class Personalizer::Adapters::Company164::ExportTemplates164::InvoicesTemplate < ExportManager::Builders::Spreadsheet

  label 'LMS Export'
  description 'LMS Export'
  configurable false
  handle :lms_export
  screen 'invoices.index'
  system :vp
  scope 'development', 2, 'L&C Ltd.'
  scope "staging", 2, 'L&C Ltd.'
  scope "production", 164, 'Satin Creditcare Network Ltd'
  validate :fetch_invoices

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

    invoices = invoices_presenter.invoices
  end

  def generate_rows
    generate_headers
    sl_no = 1
    data.find_each do |inv|
      if with_tax(inv)
        row_ap_entries(items_with_tax, inv, sl_no).map {|entry| rows << entry}
      end

      if without_tax(inv)
        row_jv_entries(items_without_tax, inv, sl_no).map {|entry| rows << entry}
      end
      inv.payments do |payment|

      end
      progress_update sl_no
      sl_no += 1
    end
  end


  ##########   AP Entries ##########
  #  invoices items with TAX component goes under ledger entry AP
  #  invoices have TDS includes comes under here
  # ################################

  def row_ap_entries(inv_items, invoice,sl_no)
    ap_entries=[]
    inv_items.each do |item|
      row = Row.new(record: item, header: header)
      {
          'S. NO.': sl_no,
          'Report ID': invoice.id,
          'Voucher Type': 'AP',
          'Period': invoice.date&.strftime("%Y%m"),
          'Voucher Date': invoice.date&.strftime("%d/%m/%Y"),
          'Description': get_description('ap',invoice),
          'Account': item.category&.gl_code,
          'Sub Account': '',
          'Department': (invoice.created_by.gl_config&.dig(:location_code).present? ? "%05d" % invoice.created_by.gl_config&.dig(:location_code) : ''),
          'Cost Center': invoice.created_by.gl_config&.dig(:cost_center),
          'Debit': item.taxable_amount&.value,
        }.each do |k, v|
        row.add k, v
        end
        ap_entries << row
        row = Row.new(record: item, header: header)
        {
            'S. NO.': sl_no,
            'Report ID': invoice.id,
            'Voucher Type': 'AP',
            'Period': invoice.date&.strftime("%Y%m"),
            'Voucher Date': invoice.date&.strftime("%d/%m/%Y"),
            'Description': get_description('ap',invoice),
            'Account': '31329011',
            'Sub Account': (invoice&.gstin_location&.state&.state_code.present? ? "%02d" % invoice&.gstin_location&.state&.state_code : ''),
            'Tax': item.tax_rate&.rate&.to_f,
            'Base Amount':item.taxable_amount&.value,
            'Debit': (item.sgst+item.cgst+item.igst),
            'Comments': 'Finly',
            'SAC': '00440294'
        }.each do |k, v|
          row.add k, v
        end
       ap_entries << row
    end
    ########## Vendor Total Bill Amount, against all ap entries
    row = Row.new(record: invoice, header: header)
    {
        'S. NO.': sl_no,
        'Report ID': invoice.id,
        'Voucher Type': 'AP',
        'Period': invoice.date&.strftime("%Y%m"),
        'Voucher Date': invoice.date&.strftime("%d/%m/%Y"),
        'Description': get_description('ap',invoice),
        'Invoice amount': invoice.net_amount.value,
        'Invoice Number': invoice.invoice_number,
        'Invoice Date': invoice.date.strftime("%d-%m-%Y"),
        'Invoice Type': 'I',
        'State': (invoice&.gstin_location&.state&.state_code.present? ? "%02d" % invoice&.gstin_location&.state&.state_code : ''),
        'Supplier GSTN': invoice&.gstin_location&.gstin,
        'Place Of Supply': (invoice&.gstin_location&.state&.state_code.present? ? "%02d" % invoice&.gstin_location&.state&.state_code : ''),
        'Account': '43181001',
        'Supplier': invoice.vendor.vendor_id,
        'Sub Account': '',
        'Credit': invoice.net_amount.value,
        'Comments': 'Finly'
    }.each do |k, v|
      row.add k, v
    end
    ap_entries << row
    ap_entries
  end

  ##########  JV Entries ########
  # Invoices items without tax component goes under ledger entry JV
  # ###############################
  def row_jv_entries(inv_items,invoice, sl_no)
    ap_entries=[]
    inv_items.each do |item|
      row = Row.new(record: item, header: header)
      {
          'S. NO.': sl_no,
          'Report ID': invoice.id,
          'Voucher Type': 'JV',
          'Period': invoice.date&.strftime("%Y%m"),
          'Voucher Date': invoice.date&.strftime("%d/%m/%Y"),
          'Description': get_description('ap',invoice),
          'Account': item.category&.gl_code,
          'Sub Account': '',
          'Department':invoice.created_by.gl_config&.dig(:location_code),
          'Cost Center': invoice.created_by.gl_config&.dig(:cost_center),
          'Debit': item.net_amount&.value,
          'Comments': 'Finly'
      }.each do |k, v|
        row.add k, v
      end

      ap_entries << row
    end
    row = Row.new(record: invoice, header: header)
    {
        'S. NO.': sl_no,
        'Report ID': invoice.id,
        'Voucher Type': 'JV',
        'Period': invoice.date&.strftime("%Y%m"),
        'Voucher Date': invoice.date&.strftime("%d/%m/%Y"),
        'Description': get_description('ap',invoice),
        'Invoice amount': invoice.net_amount.value,
        'Invoice Number': invoice.invoice_number,
        'Invoice Date': invoice.date.strftime("%d-%m-%Y"),
        'Invoice Type': 'I',
        'Account': '31352001',
        'Credit': invoice.net_amount.value,
        'Supplier': invoice.vendor&.vendor_id,
        'Comments': 'Finly'
    }.each do |k, v|
      row.add k, v
    end
    ap_entries << row
  end

  def generate_headers
        ['S. NO.',
         'Report ID',
         'Voucher Type',
         'Period',
         'Voucher Date',
         'Description',
         'Invoice amount',
         'Invoice Number',
         'Invoice Date',
         'Invoice Type',
         'State',
         'Supplier GSTN',
         'Place Of Supply',
         'Account',
         'Sub Account',
         'Department',
         'Cost Center',
         'Tax',
         'Tax Exemption(%)',
         'Base Amount',
         'Debit',
         'Credit',
         'Comments',
         'Supplier',
         'Reference Code',
         'SAC',
         'Ref. Invoice No.',
         'Payment_Mode',
     ].each do |k|
       header.add k
     end
  end


  def with_tax(invoice)
    invoice.tax_amount&.value > 0 ? true : false
  end

  def without_tax(invoice)
    invoice.tax_amount&.value <= 0 ? true : false
  end

  def with_tds(invoice)
    invoice.tds > 0 ? true : false

  end

  def get_description(v_type, inv)
    "Being Invoice No. #{invoice.invoice_number} Invoice Date #{invoice.date.strftime("%d/%m/%Y")} of #{invoice.vendor&.business_name}"
  end

end