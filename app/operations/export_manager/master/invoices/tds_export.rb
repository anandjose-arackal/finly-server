class ExportManager::Master::Invoices::TdsExport < ExportManager::Builders::Spreadsheet

  label 'Tds Export'
  description 'Tds Export'
  configurable true
  handle :tds_export
  screen 'invoices.index'
  system :vp
  validate :fetch_invoices

  attribute :invoice_id
  attribute :invoice_status
  attribute :invoice_type
  attribute :created_by
  attribute :gl_code
  attribute :tds_payable
  attribute :pan
  attribute :vendor_id
  attribute :vendor_name
  # attribute :payment_date
  attribute :amount_paid
  attribute :cgst_sgst_amount
  attribute :igst_amount
  # attribute :total_invoice_amount
  attribute :invoice_number
  attribute :invoice_date
  attribute :invoice_base_amount

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

    # start_date = Date.parse(params[:start_date].beginning_of_day) rescue false
    # end_date = Date.parse(params[:end_date].end_of_day) rescue false

    # unless start_date && end_date
    #   add_message :error, 'Invalid date provided'
    #   return
    # end
    
    invoices = invoices_presenter.invoices.where(invoice_status_id: InwardInvoiceStatus.ids_for([:partially_paid, :approved, :auto_approved, :initiated, :unpaid, :paid]))#, approved_at: start_date..end_date)
  end

  def invoice_id(invoice)
    invoice.invoice_id
  end

  def invoice_status(invoice)
    invoice&.status&.name&.humanize
  end

  def invoice_type(invoice)
    # [:tax_invoice, :advance, :non_po_invoice, :beneficiary, :proforma_invoice]
    invoice.invoice_type&.name&.titleize
  end

  def created_by(invoice)
    invoice&.created_by&.name
  end

  def gl_code(invoice)
    invoice.tds_slab&.gl_code
  end

  def tds_payable(invoice)
    invoice.tds
  end

  # TODO VENDOR LEGAL STATUS

  def pan(invoice)
    invoice.vendor.pan
  end

  def vendor_id(invoice)
    invoice.vendor.vendor_id
  end

  def vendor_name(invoice)
    invoice.vendor&.display_name
  end

  # TODO PAYMENT DATE

  def amount_paid(invoice)
    invoice.payments.successful.map {|p| p.amount.value if (p.payment_status_id == PaymentStatus.id_for(:completed))}.compact.sum
  end

  def cgst_sgst_amount(invoice)
    invoice.gst_type_id == GstType.id_for(:cgst_sgst) ? invoice.tax_amount.value / 2.0 : 0
  end

  def igst_amount(invoice)
    invoice.gst_type_id == GstType.id_for(:igst) ? invoice.tax_amount.value : 0
  end

  # TODO ADD TOTAL INVOICE AMOUNT

  def invoice_number(invoice)
    invoice.invoice_number
  end

  def invoice_date(invoice)
    invoice.date&.strftime("%d-%b-%y")
  end

  def invoice_base_amount(invoice)
    invoice.include_original_amount
  end

  # TODO TDS TAX CODE
  # TODO TDS TAX SECTION

  def tds_name(invoice)
    invoice.tds_slab.name
  end

  def tds_amount(invoice)
    invoice.tds_amount.value
  end

  def tds_rate(invoice)
    invoice.tds
  end

end