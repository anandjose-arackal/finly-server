class Personalizer::Adapters::Company196::ExportTemplates196::QuickBookTemplate < ExportManager::Builders::SpreadsheetOld

  label 'Quick Book Export'
  description 'Quick Book Export'
  configurable false
  handle :quick_book_template
  screen 'invoices.index'
  system :vp
  scope 'development', 2, 'L&C Ltd.'
  scope "staging", 2, 'L&C Ltd.'
  scope "production", 196, 'Redseer Consulting'
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
    sl_no = 1
    data.find_each do |inv|
      inv.invoice_items.each do |item|
      row = Row.new(record: item, header: header)
      {
          'Finly ref no': inv.invoice_id,
          'Invoice Date': inv.date&.strftime("%d-%b-%y"),
          'Invoice No': inv.invoice_number,
          'Vendor  Name': inv.vendor&.display_name,
          'Item Description':item.description,
          'Narration': inv.narration,
          'Category': item.category&.name,
          'Basic Value (excluding tax)':item.taxable_amount&.value,
          'IGST': item.igst,
          'SGST': item.sgst,
          'CGST':item.cgst,
          'Total Invoice Value': inv.amount&.value,
          'TDS':inv.tds_amount.value,
          'Net Invoice Value': inv.net_amount&.value,
          'Project Code': get_project_code(inv) ,
          'Invoice Link': inv.attachments&.first&.file&.url
      }.each do |k, v|
        row.add k, v
      end

      rows << row
      end
      progress_update sl_no
      sl_no += 1
    end

  end

  def get_project_code(inv)
    inv.custom_fields.with_field_key('project_code')&.first&.value&.value&.name
  end

end