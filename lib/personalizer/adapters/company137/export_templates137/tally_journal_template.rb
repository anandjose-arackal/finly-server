class Personalizer::Adapters::Company137::ExportTemplates137::TallyJournalTemplate < Personalizer::Adapters::ExportBase
  attr_accessor :headers, :contents, :procurements



  def pre_validate

  end

  def init
    company = user.company
    self.procurements = Procurement.where(procurement_type: "purchase_order", company_id: company.id).includes(:invoices,purchase_order:[:vendor,items:[:category,:total_amount]])
    self.procurements = apply_scopes(self.procurements)
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
      'Narration	Verify',
      'TALLYIMPORTSTATUS'
   ]

    self.contents = []
    procurements.each do |procurement|
      po = procurement.purchase_order
      po_invoice = procurement.invoices.first
      next if po_invoice.blank?
      grn = procurement.inward_documents.first
      po&.items&.each do |item|
      self.contents <<[
          get_voucher_type(po),
          '',
          po.submitted_at&.strftime("%d %b %y"),
          po_invoice&.invoice_number,
          po_invoice&.date&.strftime("%d %b %y"),
          po_invoice&.invoice_number,
          (po.user&.gl_config.present? ?  po.user&.gl_config&.dig(:cost_center) : ''),
          po.gstin_location&.state&.name&.upcase,
          po.vendor&.vendor_id,
          po.vendor&.business_name,
          grn&.grn_number,
          grn&.delivery_date&.strftime("%d %b %y"),
          po.purchase_order_number,
          po.delivery_date&.strftime("%d %b %y"),
          '',
          po.approved_at&.strftime("%d %b %y"),
          '',
          '',
          item&.category&.gl_code,
          item&.tax&.to_f,
          'Purchase Taxable',
          item&.taxable_amount&.value,
          'Office Expenses',
          item.total_amount&.value,
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
          ((item&.cgst.present? && item&.cgst > 0) ? get_cgst_ledger(po) : ''),
          item&.cgst,
          ((item&.sgst.present? && item&.sgst > 0) ? get_sgst_ledger(po) : ''),
          item&.sgst,
          ((item&.igst.present? && item&.igst > 0) ? get_igst_ledger(po) : ''),
          item.igst,
          (item&.tds.nil? ? "Not Applicable" : ''),
          '',
          item.tds,
          item.total_amount&.value,
          '',
          '',
          '',
      ]
    end
    end

  end


  def get_voucher_type(po)
    state_name = po.gstin_location&.state&.name
    "Purchase - #{state_name}"
  end

  def get_cgst_ledger(po)
    state_name = po.gstin_location&.state&.name&.upcase
    "Input CGST #{state_name}"
  end

  def get_sgst_ledger(po)
    state_name = po.gstin_location&.state&.name&.upcase
    "Input SGST #{state_name}"
  end

  def get_igst_ledger(po)
    state_name = po.gstin_location&.state&.name&.upcase
    "Input IGST #{state_name}"
  end

  def success
    Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents}, messages)
  end

end