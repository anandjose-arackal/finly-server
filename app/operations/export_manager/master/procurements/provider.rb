class ExportManager::Master::Procurements::Provider < ExportManager::Master::BaseMaster

  register_handle :procurement
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input
  register_fields [
                      procurement_name: {spreadsheet: true, pdf: true},
                      vendor_name: {spreadsheet: true, pdf: true},
                      vendor_business_name: {spreadsheet: false, pdf: true},
                      vendor_mobile_number: {spreadsheet: false, pdf: true},
                      vendor_state_code: {spreadsheet: false, pdf: true},
                      vendor_gst: {spreadsheet: false, pdf: true},
                      vendor_pan: {spreadsheet: false, pdf: true},
                      vendor_tds_rate: {spreadsheet: false, pdf: true},
                      vendor_tds_description: {spreadsheet: false, pdf: true},
                      vendor_type: {spreadsheet: false, pdf: true},
                      vendor_description: {spreadsheet: false, pdf: true},
                      vendor_address: {spreadsheet: false, pdf: true},
                      vendor_custom_fields: {spreadsheet: false, pdf: true},
                      policy: {spreadsheet: false, pdf: true},
                      department: {spreadsheet: true, pdf: true},
                      sub_department: {spreadsheet: true, pdf: true},
                      cost_center: {spreadsheet: true, pdf: true},
                      po_user: {spreadsheet: true, pdf: true},
                      po_status: {spreadsheet: true, pdf: true},
                      po_number: {spreadsheet: true, pdf: true},
                      po_payment_term: {spreadsheet: false, pdf: true},
                      po_date: {spreadsheet: true, pdf: true},
                      po_delivery_date: {spreadsheet: false, pdf: true},
                      po_submitted_on: {spreadsheet: false, pdf: true},
                      is_po_approved: {spreadsheet: true, pdf: true},
                      po_approved_on: {spreadsheet: false, pdf: true},
                      po_sent_on: {spreadsheet: false, pdf: true},
                      po_base_value: {spreadsheet: true, pdf: true},
                      po_cgst: {spreadsheet: false, pdf: true},
                      po_sgst: {spreadsheet: false, pdf: true},
                      po_igst: {spreadsheet: false, pdf: true},
                      po_line_items_count: {spreadsheet: false, pdf: true},
                      po_purchase_address: {spreadsheet: true, pdf: true},
                      po_delivery_address: {spreadsheet: true, pdf: true},
                      po_custom_fields: {spreadsheet: false, pdf: true},
                      inwards_status: {spreadsheet: false, pdf: true},
                      last_inward_received_on: {spreadsheet: false, pdf: true},
                      invoice_number: {spreadsheet: true, pdf: true},
                      invoice_payment_term: {spreadsheet: false, pdf: true},
                      invoice_delivery_date: {spreadsheet: false, pdf: true},
                      invoice_submitted_on: {spreadsheet: false, pdf: true},
                      invoice_approved_on: {spreadsheet: false, pdf: true},
                      is_invoice_approved: {spreadsheet: true, pdf: true},
                      invoice_sent_on: {spreadsheet: false, pdf: true},
                      invoice_cgst: {spreadsheet: false, pdf: true},
                      invoice_sgst: {spreadsheet: false, pdf: true},
                      invoice_igst: {spreadsheet: false, pdf: true},
                      invoice_tds_type: {spreadsheet: true, pdf: true},
                      invoice_tds_rate: {spreadsheet: true, pdf: true},
                      invoice_tds_amount: {spreadsheet: false, pdf: true},
                      invoice_total_amount: {spreadsheet: true, pdf: true},
                      invoice_total_amount_after_tds: {spreadsheet: false, pdf: true},
                      invoice_payable_amount: {spreadsheet: false, pdf: true},
                      invoice_line_items_count: {spreadsheet: false, pdf: true},
                      invoice_purchase_address: {spreadsheet: false, pdf: true},
                      invoice_delivery_address: {spreadsheet: false, pdf: true},
                      invoice_custom_fields: {spreadsheet: false, pdf: true}
                  ]

  def input
    result = ::Procurements::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    result.procurements
  end

  def procurement_name(procurement)
    procurement.name
  end

  def vendor_name(procurement)
    procurement.vendor&.name
  end

  def vendor_business_name(procurement)
    procurement.vendor&.business_name
  end

  def vendor_mobile_number(procurement)
    procurement.vendor&.mobile_number
  end

  def vendor_state_code(procurement)
    procurement.vendor&.state_code
  end

  def vendor_pan(procurement)
    procurement.vendor&.pan
  end

  def vendor_gst(procurement)
    procurement.vendor&.gst
  end

  def vendor_tds_rate(procurement)
    # todo
  end

  def vendor_tds_description(procurement)
    # todo
  end

  def vendor_type(procurement)
    procurement.vendor&.vendor_type&.name
  end

  def vendor_description(procurement)
    procurement.vendor&.description
  end

  def vendor_address(procurement)
    procurement.vendor&.address
  end

  def vendor_custom_fields(procurement)
    # todo
  end

  def policy(procurement)
    procurement.type_entity&.policy&.name
  end

  def department(procurement)
    procurement.type_entity&.department&.name
  end

  def sub_department(procurement)
    procurement.type_entity&.sub_department&.name
  end

  def cost_center(procurement)
    procurement.type_entity&.cost_center&.name
  end

  def po_user(procurement)
    if procurement.purchase_order.present?
      purchase_order(procurement)&.user&.name
    end
  end

  def po_status(procurement)
    procurement.purchase_order&.status&.name&.humanize
  end

  def po_number(procurement)
    purchase_order(procurement)&.po_number
  end

  def po_payment_term(procurement)
    purchase_order(procurement)&.payment_term&.name
  end

  def po_delivery_date(procurement)
    DateUtils.date_formatted purchase_order(procurement)&.delivery_date
  end

  def po_date(procurement)
    DateUtils.date_formatted purchase_order(procurement)&.created_at
  end

  def po_submitted_on(procurement)
    # todo
  end

  def is_po_approved(procurement)
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :closed, :sent_to_vendor).include?(purchase_order(procurement)&.purchase_order_status_id) ? 'Yes' : 'No'
  end

  def po_approved_on(procurement)
    # todo
  end

  def po_sent_on(procurement)
    # todo
  end

  def po_base_value(procurement)
    purchase_order(procurement)&.total_before_tax&.value
  end

  def po_cgst(procurement)
    if purchase_order(procurement)&.gst_type&.cgst?
      value = purchase_order(procurement)&.tax_amount&.value
      if value
        return value / 2
      end
    end
  end

  def po_sgst(procurement)
    po_cgst(procurement)
  end

  def po_igst(procurement)
    if purchase_order(procurement)&.gst_type&.igst?
      purchase_order(procurement)&.tax_amount&.value
    end
  end

  def po_line_items_count(procurement)
    # todo
  end

  def po_purchase_address(procurement)
    purchase_order(procurement)&.billing_address
  end

  def po_delivery_address(procurement)
    purchase_order(procurement)&.shipping_address
  end

  def po_custom_fields(procurement)
    # todo
  end

  def inwards_status(procurement)
    # todo
  end

  def last_inward_received_on(procurement)
    # todo
  end

  def invoice_number(procurement)
    procurement.invoices&.first&.invoice_number
  end

  def invoice_payment_term(procurement)
    # todo
  end

  def invoice_delivery_date(procurement)

  end

  def invoice_submitted_on(procurement)
    # todo
  end

  def invoice_approved_on(procurement)
    # todo
  end

  def is_invoice_approved(procurement)
    InwardInvoiceStatus.ids_for(:partially_paid, :paid, :approved, :rejected, :auto_approved, :closed).include?(invoice(procurement)&.invoice_status_id) ? 'Yes' : 'No'
  end

  def invoice_sent_on(procurement)

  end

  def invoice_cgst(procurement)

  end

  def invoice_sgst(procurement)

  end

  def invoice_igst(procurement)

  end

  def invoice_tds_type(procurement)
    invoice(procurement)&.tds_slab&.name
  end

  def invoice_tds_rate(procurement)
    invoice(procurement)&.tds_slab&.tds
  end


  def invoice_tds_amount(procurement)
    invoice(procurement)&.tds_amount&.value
  end
  
  def invoice_total_amount(procurement)
    invoice(procurement)&.net_amount&.value
  end

  def invoice_total_amount_after_tds(procurement)
    invoice_amount = invoice_total_amount(procurement)
    tds_amount = invoice_tds_amount(procurement) || 0
    if invoice_amount
      invoice_amount - tds_amount
    end
  end

  def invoice_payable_amount(procurement)

  end

  def invoice_line_items_count(procurement)

  end

  def invoice_purchase_address(procurement)

  end

  def invoice_delivery_address(procurement)

  end

  def invoice_custom_fields(procurement)
    # todo
  end

  protected
  def invoice(procurement)
    procurement&.invoices&.last
  end

  def purchase_order(procurement)
    procurement&.purchase_order
  end


end