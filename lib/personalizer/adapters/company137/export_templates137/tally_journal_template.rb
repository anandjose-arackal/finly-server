class Personalizer::Adapters::Company137::ExportTemplates137::TallyJournalTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :procurements


  def pre_validate

  end

  def init
    company = user.company
    invoices_presenter = BankTransfer::InwardInvoices::Index.(user, params)

    unless invoices_presenter.success?
      add_message :error, invoices_presenter.messages[:error]
      return
    end
    invoices = invoices_presenter.invoices.where(invoice_type: [InwardInvoiceType.id_for(:tax_invoice), InwardInvoiceType.id_for(:non_po_invoice)])
    self.headers = [
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
        'Amount',
        'Interim Reverse Charge IGST',
        'Amount',
        'Reverse Charge IGST',
        'Amount',
        'Interim Reverse Charge CGST',
        'Amount',
        'Reverse Charge CGST',
        'Amount',
        'Interim Reverse Charge SGST',
        'Amount',
        'Reverse Charge SGST',
        'Amount',
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
    ]

    self.contents = []
    invoices.each do |invoice|
      grn = invoice.procurement&.inward_documents&.first
      invoice&.items&.each do |item|
        self.contents << [
            get_voucher_type(invoice),
            '',
            Date.today&.strftime("%b %d, %y"),
            invoice&.invoice_number,
            invoice&.date&.strftime("%b %d, %y"),
            invoice&.invoice_number,
            invoice.cost_center&.name,
            invoice.gstin_location&.state&.name&.upcase,
            invoice.vendor&.vendor_id,
            invoice.vendor&.business_name,
            grn&.grn_number,
            grn&.delivery_date&.strftime("%d %b %y"),
            get_order_number(invoice),
            get_order_date(invoice),
            '',
            invoice.approved_at&.strftime("%d %b %y"),
            '',
            '',
            item&.category&.gl_code,
            item&.tax&.to_f,
            'Purchase Taxable',
            item&.taxable_amount&.value,
            item&.category&.name,
            item&.net_amount&.value,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            ((item&.cgst.present? && item&.cgst > 0) ? get_cgst_ledger(invoice) : ''),
            item&.cgst,
            ((item&.sgst.present? && item&.sgst > 0) ? get_sgst_ledger(invoice) : ''),
            item&.sgst,
            ((item&.igst.present? && item&.igst > 0) ? get_igst_ledger(invoice) : ''),
            item.igst,
            '',
            '',
            '',
            item&.net_amount&.value,
            '',
            retrieve_approved_by(invoice),
            ''
        ]
      end
    end

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
    if invoice.invoice_type == 'non_po_invoice'
      order_number = invoice.invoice_id
    elsif invoice.invoice_type == 'tax_invoice'
      order_number = invoice&.procurement&.purchase_order&.purchase_order_number
    end
    order_number
  end

  def get_order_date(invoice)
    if invoice.invoice_type == 'non_po_invoice'
    elsif invoice.invoice_type == 'tax_invoice'
      invoice.procurement&.purchase_order&.delivery_date&.strftime("%b %d, %y")
    end
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end