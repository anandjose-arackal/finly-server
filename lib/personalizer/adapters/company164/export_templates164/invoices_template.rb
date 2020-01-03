class Personalizer::Adapters::Company164::ExportTemplates164::InvoicesTemplate < ExportManager::Builders::Spreadsheet

  label 'Export 2'
  description 'Invoice'
  configurable false
  handle :invoices
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
    InvoiceLineItem.where(parent_type: 'Invoice').includes({purchase_order_item: :purchase_order}, :category, :department, :tax_rate, :cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency}, :discount_amount, parent: [:invoice_attachments, :invoice_type, :vendor, :delivery_location, :invoice_status, :location, :tds_slab, :advance_amount, :balance_due, :discount_amount, :created_by, :gstin_location, {dlrms: [:reviewer, :taken_control_by, :forwarded_to]}, {custom_fields: [:value, :field_configuration]}, {tds_amount: :currency}, :amount, {procurement: [{purchase_order: :advance_amount}]}]).where(parent_id: invoices.pluck(:id))
  end

  def generate_rows
    [
        'S. NO.',
        'Report ID', 'Voucher Type',
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
        'Remarks/Notes/Explanation'
    ].each do |label|
      header.add label
    end

    sl_no = 1
    data.find_each do |inv|
      row = [
          sl_no,
          inv.invoice_id,
          'BP',
          inv.date&.strftime("%Y%m"),
          inv.date&.strftime("%d/%m/%Y"),
          get_description(inv),
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '43181001',
          '',
          '',
          '',
          '',
          '',
          '',
          (inv.paid_amount&.value || 0.0),
          '',
          '',
          inv.receiving_account_id,
          inv.payments&.first&.reference_resource&.bank_reference_number
      ]
      rows << row
      row = [sl_no,
             inv.invoice_id,
             'BP',
             inv.date&.strftime("%Y%m"),
             inv.date&.strftime("%d/%m/%Y"),
             get_description(inv),
             '',
             '',
             '',
             '',
             '',
             '',
             '',
             '61110004',
             inv.created_by_id,
             '',
             '',
             '',
             '',
             '',
             '',
             (inv.paid_amount&.value || 0.0),
             '',
             inv.receiving_account_id,
             inv.payments&.first&.reference_resource&.bank_reference_number
      ]
      rows << row
      progress_update sl_no
      sl_no += 1
    end

  end

end