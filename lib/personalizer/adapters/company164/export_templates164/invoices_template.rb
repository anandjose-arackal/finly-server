class Personalizer::Adapters::Company164::ExportTemplates164::InvoicesTemplate < ExportManager::Builders::Spreadsheet

  label 'Export 2'
  description 'Invoice'
  configurable false
  handle :lms_export
  screen 'invoices.index'
  system :vp
  # scope "development", 2, 'L&C Ltd.'
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
    # InvoiceLineItem.where(parent_type: 'Invoice').includes({purchase_order_item: :purchase_order}, :category, :department, :tax_rate, :cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency}, :discount_amount, parent: [:invoice_attachments, :invoice_type, :vendor, :delivery_location, :invoice_status, :location, :tds_slab, :advance_amount, :balance_due, :discount_amount, :created_by, :gstin_location, {dlrms: [:reviewer, :taken_control_by, :forwarded_to]}, {custom_fields: [:value, :field_configuration]}, {tds_amount: :currency}, :amount, {procurement: [{purchase_order: :advance_amount}]}]).where(parent_id: invoices.pluck(:id))
  end

  def generate_rows
    sl_no = 1
    data.find_each do |inv|
      row = Row.new(record: inv, header: header)
      {
          'S. NO.': sl_no,
          'Report ID': inv.invoice_id,
          'Voucher Type': 'BP',
          'Period': inv.date&.strftime("%Y%m"),
          'Voucher Date': inv.date&.strftime("%d/%m/%Y"),
          'Description': get_description(inv),
          'Invoice amount': '',
          'Invoice Number': '',
          'Invoice Date': '',
          'Invoice Type': '',
          'State': '',
          'Supplier GSTN': '',
          'Place Of Supply': '',
          'Account': '43181001',
          'Sub Account': '',
          'Department': '',
          'Cost Center': '',
          'Tax': '',
          'Tax Exemption(%)': '',
          'Base Amount': '',
          'Debit': (inv.paid_amount&.value || 0.0),
          'Credit': '',
          'Comments': '',
          'Supplier': inv.receiving_account_id,
          'Reference Code': inv.payments&.first&.reference_resource&.bank_reference_number,
          'SAC': "",
          'Ref. Invoice No.': "",
          'Remarks/Notes/Explanation': "",
      }.each do |k, v|
        row.add k, v
      end
      row = Row.new(record: inv, header: header)
      rows << row
      {
          'S. NO.': sl_no,
          'Report ID': inv.invoice_id,
          'Voucher Type': 'BP',
          'Period': inv.date&.strftime("%Y%m"),
          'Voucher Date': inv.date&.strftime("%d/%m/%Y"),
          'Description': get_description(inv),
          'Invoice amount': '',
          'Invoice Number': '',
          'Invoice Date': '',
          'Invoice Type': '',
          'State': '',
          'Supplier GSTN': '',
          'Place Of Supply': '',
          'Account': '61110004',
          'Sub Account': inv.created_by&.name,
          'Department': '',
          'Cost Center': '',
          'Tax': '',
          'Tax Exemption(%)': '',
          'Base Amount': '',
          'Debit': '',
          'Credit': (inv.paid_amount&.value || 0.0),
          'Comments': '',
          'Supplier': inv.receiving_account_id,
          'Reference Code': inv.payments&.first&.reference_resource&.bank_reference_number,
          'SAC': "",
          'Ref. Invoice No.': "",
          'Remarks/Notes/Explanation': "",
      }.each do |k, v|
        row.add k, v
      end
      rows << row
      progress_update sl_no
      sl_no += 1
    end

  end

  def get_description(inv)
    payment_ids = inv.payments&.pluck(:id)&.join(',')
    "Being Payment made against various Payment IDs #{payment_ids}"
  end

end