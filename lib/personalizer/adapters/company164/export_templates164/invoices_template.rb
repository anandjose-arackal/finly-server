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
      items_with_tax = with_tax(inv.invoice_items)
      rows << row_ap_entries(items_with_tax,inv) if items_with_tax.present?

      items_without_tax = without_tax(inv.invoice_items)
      rows << row_jv_entries(items_without_tax, inv) if items_without_tax.present?
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

  def row_ap_entries(inv_items, invoice)
    ap_entries=[]
    inv_items.each do |item|
      row = Row.new(record: item, header: header)
      {
          'S. NO.': sl_no,
          'Report ID': invoice.id,
          'Voucher Type': 'AP',
          'Period': invoice.date&.strftime("%Y%m"),
          'Voucher Date': inv.date&.strftime("%d/%m/%Y"),
          'Description': get_description('ap',inv),
          'Account': item.category&.gl_code,
          'Sub Account': '',
          'Department':invoice.created_by.gl_config&.dig(:location_code),
          'Cost Center': invoice.created_by.gl_config&.dig(:cost_center),
          'Debit': item.taxable_amount&.value,
          'Credit': '',
          'Comments': '',
          'Supplier': inv.receiving_account_id,
          'Reference Code': inv.payments&.first&.reference_resource&.bank_reference_number,
        }.each do |k, v|
        row.add k, v
        ap_entries << row
        {
            'S. NO.': sl_no,
            'Report ID': invoice.id,
            'Voucher Type': 'AP',
            'Period': invoice.date&.strftime("%Y%m"),
            'Voucher Date': inv.date&.strftime("%d/%m/%Y"),
            'Description': get_description('ap',inv),
            'Account': '31329011',
            'Sub Account': invoice&.gst_location&.state&.state_code,
            'TAX': '',
            'Credit': '',
            'Comments': '',
            'Supplier': inv.receiving_account_id,
            'Reference Code': inv.payments&.first&.reference_resource&.bank_reference_number,
        }.each do |k, v|
          row.add k, v
      end
    end
  end

  #########    JV Entries ########
  # Invoices items without tax component goes under ledger entry JV
  # ###############################
  def row_jv_entries(inv_items,invoice)
    inv_items
  end

  def generate_headers
     header = Header.new()
        [ 'S. NO.',
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
         'Remarks/Notes/Explanation',
     ].each do |k|
       header.add k
     end
  end

  def has_tds?(inv)

  end

  def has_gst?(inv)

  end

  def with_tax(items)
    items.where('sgst > 0 || cgst > 0 || igst > 0')
  end

  def without_tax(items)
   items.where('sgst = 0 && csgt = 0 && igst = 0')
  end


  def get_description(v_type, inv)
    case v_type
    when 'ap'
      return "Being expenses settled against report ID #{inv.id} of #{inv.created_by.name} with #{inv.created_by.profile.employee_id}"
    when 'jv'
    end
  end

end