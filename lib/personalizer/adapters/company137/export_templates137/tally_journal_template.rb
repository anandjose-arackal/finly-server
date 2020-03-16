class Personalizer::Adapters::Company137::ExportTemplates137::TallyJournalTemplate < ExportManager::Builders::Spreadsheet

  label 'Tally Invoices Export'
  description 'Tally Invoices Export'
  configurable false
  handle :tally_invoices_export
  screen 'invoices.index'
  system :vp
  scope 'development', 2, 'L&C Ltd.'
  scope "staging", 2, 'L&C Ltd.'
  scope "production", 137, 'Metropolitan Stock Exchange'
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

    invoices = invoices_presenter.invoices.where(invoice_status_id: Invoice.finance_associated_status_ids)
  end

  def generate_rows
    generate_headers
    sl_no = 0
    data.find_each do |inv|
      grn = inv.procurement&.inward_documents&.first
      inv.items.each do |item|
        line_item_entries(inv, item, grn).map{|entry| rows << entry}
      end
      sl_no +=1
      progress_update sl_no
    end
  end

  def line_item_entries(invoice, item, grn)
      entries=[]
      row = ExportManager::Builders::Spreadsheet::Row.new(record: item, header: header)
      {
        'Vch Type': get_voucher_type(invoice),
        'Date':Date.today&.strftime("%b %d, %y"),
        'Supplier Inv No':invoice&.invoice_number,
        'Supplier Inv Date':invoice&.date&.strftime("%b %d, %y"),
        'Ref No':invoice&.invoice_number,
        'Cost center 1': invoice.cost_center&.name,
        'Cost Center':invoice.gstin_location&.state&.name&.upcase,
        'Vendor Code':invoice.vendor&.vendor_id,
        'Vendor Name':invoice.vendor&.business_name,
        'Receipt Note No':grn&.grn_number,
        'Receipt Note Date':grn&.delivery_date&.strftime("%d %b %y"),
        'Order No':get_order_number(invoice),
        'Order Date':get_order_date(invoice),
        'Approval Date':invoice.approved_at&.strftime("%d %b %y"),
        'GL Code':item&.category&.gl_code,
        'GST Rate':item&.tax&.to_f,
        'Tax Classification':'Purchase Taxable',
        'Taxble value':item&.taxable_amount&.value,
        'Ledger Name':item&.category&.name,
        'Amount':item&.net_amount&.value,
        'CGST Ledger':((item&.cgst.present? && item&.cgst > 0) ? get_cgst_ledger(invoice) : ''),
        'CGST Amt':item&.cgst,
        'SGST Ledger':((item&.sgst.present? && item&.sgst > 0) ? get_sgst_ledger(invoice) : ''),
        'SGST Amt':item&.sgst,
        'IGST Ledger':((item&.igst.present? && item&.igst > 0) ? get_igst_ledger(invoice) : ''),
        'IGST Amt':item.igst,
        'Total':item&.net_amount&.value,
        'Verify':retrieve_approved_by(invoice)
      }.each do |k, v|
        row.add k, v
      end
      entries << row

  end

###############################################################################
# ExportManager::Builders::Spreadsheet::Row  contains array of hash
# Hash not support duplicate key
# Below method is jugad to handle this condition
###############################################################################

  def generate_spreadsheet
    contents = []
    self.rows.each do |row|
      contents << row.build
    end
    headers = header.list.map{ |h| h.include?("Amount") ? 'Amount' : h }

    exporter = Exporter::Spreadsheet.new(self.user, {headers: headers, contents: contents})
    file = Paperclip::Tempfile.new(file_name)
    open(file.path, 'wb') do |f|
      case format
      when :csv
        f.write exporter.generate_csv
      when :xls
        f.write exporter.generate_xls
      end
    end
    file
  end


  def get_voucher_type(invoice)
    state_name = invoice.gstin_location&.state&.name
    "Purchase - #{state_name}"
  end

  def get_cgst_ledger(invoice)
    state_name = invoice.gstin_location&.state&.name&.upcase
    "Input CGST #{state_name}"
  end

  def get_sgst_ledger(invoice)
    state_name = invoice.gstin_location&.state&.name&.upcase
    "Input SGST #{state_name}"
  end

  def get_igst_ledger(invoice)
    state_name = invoice.gstin_location&.state&.name&.upcase
    "Input IGST #{state_name}"
  end

  def retrieve_approved_by(invoice)
    return '' if invoice&.dlrms.blank?
    dlrm = invoice.dlrms.where(action_id: TrailAction.id_for(:approve)).first
    if dlrm&.taken_control_by_id&.present?
      return dlrm.taken_control_by&.name
    elsif dlrm&.forwarded_by_id&.present?
      return dlrm&.forwarded_by&.name
    elsif dlrm&.reviewer_id.present?
      return dlrm.reviewer&.name
    end
    ''
  end

  def get_order_number(invoice)
    order_number = ""
    if invoice.invoice_type&.name == 'non_po_invoice'
      order_number = invoice.invoice_id
    elsif invoice.invoice_type&.name == 'tax_invoice'
      order_number = invoice&.procurement&.purchase_order&.purchase_order_number
    end
    order_number
  end

  def get_order_date(invoice)
    if invoice.invoice_type&.name == 'non_po_invoice'
    elsif invoice.invoice_type&.name == 'tax_invoice'
      invoice.procurement&.purchase_order&.delivery_date&.strftime("%b %d, %y")
    end
  end

  def generate_headers
    [
        'Vch Type',
        'Tally VoucherVch No.',
        'Date',
        'Supplier Inv No',
        'Supplier Inv Date',
        'Ref No',
        'Cost center 1',
        'Cost Center',
        'Vendor Code',
        'Vendor Name',
        'Receipt Note No',
        'Receipt Note Date',
        'Order No',
        'Order Date',
        'Approval No',
        'Approval Date',
        'Period From',
        'Period TO',
        'GL Code',
        'GST Rate',
        'Tax Classification',
        'Taxble value',
        'Ledger Name',
        'Amount1',
        'Interim Reverse Charge IGST',
        'Amount2',
        'Reverse Charge IGST',
        'Amount3',
        'Interim Reverse Charge CGST',
        'Amount4',
        'Reverse Charge CGST',
        'Amount5',
        'Interim Reverse Charge SGST',
        'Amount6',
        'Reverse Charge SGST',
        'Amount7',
        'CGST Ledger',
        'CGST Amt',
        'SGST Ledger',
        'SGST Amt',
        'IGST Ledger',
        'IGST Amt',
        'TDS Classification',
        'TDS Ledger',
        'TDS AMT',
        'Total',
        'Narration',
        'Verify',
        'TALLYIMPORTSTATUS'
    ].each do |k|
      header.add k
    end
  end

end