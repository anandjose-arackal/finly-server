class ExportManager::Master::Invoices::TdsExport < ExportManager::Builders::Spreadsheet

  label 'Tds Export'
  description 'Tds Export'
  configurable true
  handle :tds_export
  screen 'invoices.index'
  system :vp

  has_template true

  attribute :invoice_number
  attribute :finly_ref_no
  attribute :invoice_date
  attribute :invoice_status
  attribute :invoice_type
  attribute :created_by
  attribute :tds_gl_code
  attribute :legal_status
  attribute :pan
  attribute :vendor_id
  attribute :vendor_name
  # attribute :payment_date
  attribute :total_invoice_amount
  attribute :invoice_base_amount
  attribute :tds_name
  attribute :tds_payable
  attribute :tds_amount
  attribute :cgst_sgst_amount
  attribute :igst_amount
  attribute :amount_paid

  def input
    invoices = Resolver::Router.dispatch('invoices.default', {current_user: user, params: params})
    invoices.where(invoice_status_id: InwardInvoiceStatus.ids_for([:partially_paid, :paid])).left_joins(:payments)
  end

  def finly_ref_no(invoice)
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

  def tds_gl_code(invoice)
    invoice.tds_slab&.gl_code
  end

  def tds_payable(invoice)
    invoice.tds
  end

  # TODO VENDOR LEGAL STATUS DONE

  def legal_status(invoice)
    invoice.vendor_location&.gstin_master&.constitution_of_business
  end

  def pan(invoice)
    invoice.vendor&.pan
  end

  def vendor_id(invoice)
    invoice.vendor&.vendor_id
  end

  def vendor_name(invoice)
    invoice.vendor&.display_name
  end

  # TODO PAYMENT DATE DONE

  def payment_date(invoice)
    invoice.payments.order(created_at: :desc).first&.created_at&.strftime("%d-%b-%y")
  end

  def amount_paid(invoice)
    invoice.payments.successful.map {|p| p.amount&.value if (p.payment_status_id == PaymentStatus.id_for(:completed))}.compact.sum
  end

  def cgst_sgst_amount(invoice)
    invoice.gst_type_id == GstType.id_for(:cgst_sgst) ? invoice.tax_amount&.value.to_f / 2.0 : 0
  end

  def igst_amount(invoice)
    invoice.gst_type_id == GstType.id_for(:igst) ? invoice.tax_amount&.value.to_f : 0
  end

  # TODO ADD TOTAL INVOICE AMOUNT amt + gst DONE

  def total_invoice_amount(invoice)
    invoice.gross_amount&.value.to_f + invoice.tax_amount&.value.to_f
  end

  def invoice_number(invoice)
    "\t#{invoice.invoice_number}"
  end

  def invoice_date(invoice)
    invoice.date&.strftime("%d-%b-%y")
  end

  def invoice_base_amount(invoice)
    invoice.include_original_amount
  end

  # TODO TDS TAX CODE DONE merged to tds_name
  # TODO TDS TAX SECTION DONE

  def tds_name(invoice)
    invoice.tds_slab&.name
  end

  def tds_amount(invoice)
    invoice.tds_amount&.value
  end

  def tds_rate(invoice)
    invoice.tds
  end

end
