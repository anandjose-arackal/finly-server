class ExportManager::Master::PurchaseOrders::Index < ExportManager::Builders::Spreadsheet

  label 'Spreadsheet'
  description 'Purchase Orders Export'
  configurable true
  system :vp
  resolver 'purchase_orders.default'
  screen ['purchase_orders.index', 'po_advances.index']
  handle :purchase_orders
  # validate :input

  attribute :procurement_name
  attribute :vendor_name
  attribute :vendor_business_name
  attribute :vendor_mobile_number
  attribute :vendor_state_code
  attribute :vendor_gstin
  attribute :vendor_pan
  attribute :vendor_tds_rate
  attribute :vendor_tds_description
  attribute :vendor_type
  attribute :vendor_description
  attribute :vendor_address
  attribute :vendor_custom_fields
  attribute :approval_pending_level_number
  attribute :approval_pending_level_name
  attribute :approval_pending_reviewers
  attribute :approved_reviewers
  attribute :policy
  attribute :department
  attribute :sub_department
  attribute :cost_center
  attribute :po_user
  attribute :po_status
  attribute :po_number
  attribute :po_payment_term
  attribute :po_creation_date
  attribute :po_closed_date
  attribute :po_delivery_date
  attribute :po_submitted_on
  attribute :is_po_approved
  attribute :po_approved_on
  attribute :po_sent_on
  attribute :po_base_value
  attribute :po_cgst
  attribute :po_sgst
  attribute :po_igst
  attribute :po_line_items_count
  attribute :po_purchase_address
  attribute :po_delivery_address
  attribute :po_custom_fields
  attribute :inwards_status
  attribute :last_inward_received_on
  attribute :invoice_number
  attribute :invoice_id
  attribute :invoice_payment_term
  attribute :invoice_delivery_date
  attribute :invoice_submitted_on
  attribute :invoice_approved_on
  attribute :is_invoice_approved
  attribute :invoice_sent_on
  attribute :invoice_cgst
  attribute :invoice_sgst
  attribute :invoice_igst
  attribute :invoice_tds_type
  attribute :invoice_tds_rate
  attribute :invoice_tds_amount
  attribute :invoice_base_amount
  attribute :invoice_discount_amount
  attribute :invoice_total_amount
  attribute :invoice_total_amount_after_tds
  attribute :invoice_payable_amount
  attribute :invoice_line_items_count
  attribute :invoice_purchase_address
  attribute :invoice_delivery_address
  attribute :invoice_custom_fields

  # def input
  #   # if params[:filter_po_status].present?
  #   #   unless params[:filter_po_status].is_a?(Integer)
  #   #     params[:filter_po_status] = PurchaseOrderStatus.id_for(params[:filter_po_status]&.to_sym)
  #   #   end
  #   # end
  #   result = ::Procurements::PurchaseOrders::Index.(user, params)
  #   unless result.success?
  #     add_message :error, result.messages[:error]
  #     return
  #   end
  #   result.purchase_orders.includes(:policy, :vendor, :gstin_location, :controlling_level, :level, :department, :sub_department, :cost_center, :user, :status, :total_before_tax, procurement: [invoices: [:gst_type, :tax_amount, :tds_slab, :discount_amount, :net_amount, :invoice_items]])
  # end

  def procurement_name(purchase_order)
    purchase_order.procurement.name
  end

  def vendor_name(purchase_order)
    purchase_order.procurement.vendor&.display_name
  end

  def vendor_business_name(purchase_order)
    purchase_order.procurement.vendor&.business_name
  end

  def vendor_mobile_number(purchase_order)
    purchase_order.procurement.vendor&.mobile_number
  end

  def vendor_state_code(purchase_order)
    purchase_order.procurement.vendor&.state_code
  end

  def vendor_pan(purchase_order)
    purchase_order.procurement.vendor&.pan
  end

  def vendor_gstin(purchase_order)
    purchase_order.gstin_location&.gstin
  end

  def approval_pending_level_number(purchase_order)
    purchase_order&.controlling_level&.level_number
  end

  def approval_pending_level_name(purchase_order)
    purchase_order&.controlling_level&.name
  end

  def approval_pending_reviewers(purchase_order)
    purchase_order&.get_reviewers&.map(&:name)&.join(", ")
  end

  def approved_reviewers(purchase_order)
    purchase_order&.dlrms&.where(action_id: TrailAction.id_for(:approve))&.includes(:reviewer)&.map {|dlr| dlr.reviewer.name}&.join(" ,")
  end

  def vendor_tds_rate(purchase_order)
    # todo
  end

  def vendor_tds_description(purchase_order)
    # todo
  end

  def vendor_type(purchase_order)
    purchase_order.procurement.vendor&.vendor_type&.name
  end

  def vendor_description(purchase_order)
    purchase_order.procurement.vendor&.description
  end

  def vendor_address(purchase_order)
    purchase_order.procurement.vendor&.address
  end

  def vendor_custom_fields(purchase_order)
    # todo
  end

  def policy(purchase_order)
    purchase_order.procurement.type_entity&.policy&.name
  end

  def department(purchase_order)
    purchase_order.procurement.type_entity&.department&.name
  end

  def sub_department(purchase_order)
    purchase_order.procurement.type_entity&.sub_department&.name
  end

  def cost_center(purchase_order)
    purchase_order.procurement.type_entity&.cost_center&.name
  end

  def po_user(purchase_order)
    if purchase_order.procurement.purchase_order.present?
      purchase_order&.user&.name
    end
  end

  def po_status(purchase_order)
    purchase_order.procurement.purchase_order&.status&.name&.humanize
  end

  def po_number(purchase_order)
    purchase_order&.po_number
  end

  def po_payment_term(purchase_order)
    purchase_order&.payment_term&.name
  end

  def po_delivery_date(purchase_order)
    purchase_order&.delivery_date&.strftime("%d-%b-%Y")
  end

  def po_creation_date(purchase_order)
    purchase_order&.created_at&.strftime("%d-%b-%Y")
  end

  def po_closed_date(purchase_order)
    purchase_order.trails&.find_by(action_id: TrailAction.id_for(:close))&.created_at&.strftime("%d-%b-%Y")
  end

  def po_submitted_on(purchase_order)
    # todo
    purchase_order.trails&.where(action_id: TrailAction.id_for(:submit))&.last&.created_at&.strftime("%d-%b-%Y")
  end

  def is_po_approved(purchase_order)
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :closed, :sent_to_vendor, :vendor_confirmed).include?(purchase_order&.purchase_order_status_id) ? 'Yes' : 'No'
  end

  def po_approved_on(purchase_order)
    # todo
  end

  def po_sent_on(purchase_order)
    # todo
  end

  def po_base_value(purchase_order)
    purchase_order&.total_before_tax&.value
  end

  def po_cgst(purchase_order)
    if purchase_order&.gst_type&.cgst?
      value = purchase_order&.tax_amount&.value
      if value
        return value / 2
      end
    end
  end

  def po_sgst(purchase_order)
    po_cgst(purchase_order)
  end

  def po_igst(purchase_order)
    if purchase_order&.gst_type&.igst?
      purchase_order&.tax_amount&.value
    end
  end

  def po_line_items_count(purchase_order)
    # todo
  end

  def po_purchase_address(purchase_order)
    purchase_order&.billing_address
  end

  def po_delivery_address(purchase_order)
    purchase_order&.shipping_address
  end

  def po_custom_fields(purchase_order)
    # todo
  end

  def inwards_status(purchase_order)
    # todo
  end

  def last_inward_received_on(purchase_order)
    # todo
  end

  def invoice_number(purchase_order)
    purchase_order.procurement.invoices&.first&.invoice_number
  end

  def invoice_id(purchase_order)
    purchase_order.procurement.invoices.first&.invoice_id
  end

  def invoice_payment_term(purchase_order)
    # todo
  end

  def invoice_delivery_date(purchase_order)

  end

  def invoice_submitted_on(purchase_order)
    # todo
  end

  def invoice_approved_on(purchase_order)
    # todo
  end

  def is_invoice_approved(purchase_order)
    InwardInvoiceStatus.ids_for(:partially_paid, :paid, :approved, :rejected, :auto_approved, :closed).include?(invoice(purchase_order)&.invoice_status_id) ? 'Yes' : 'No'
  end

  def invoice_sent_on(purchase_order)

  end

  def invoice_cgst(purchase_order)
    if invoice(purchase_order)&.gst_type&.cgst?
      value = invoice(purchase_order)&.tax_amount&.value
      if value
        return value / 2
      end
    end
  end

  def invoice_sgst(purchase_order)
    invoice_cgst(purchase_order)
  end

  def invoice_igst(purchase_order)
    if invoice(purchase_order)&.gst_type&.igst?
      invoice(purchase_order)&.tax_amount&.value
    end
  end

  def invoice_tds_type(purchase_order)
    invoice(purchase_order)&.tds_slab&.name
  end

  def invoice_tds_rate(purchase_order)
    invoice(purchase_order)&.tds_slab&.tds
  end

  def invoice_base_amount(purchase_order)
    invoice(purchase_order)&.item_amounts_total
  end

  def invoice_discount_amount(purchase_order)
    invoice(purchase_order)&.discount_amount&.value
  end

  def invoice_tds_amount(purchase_order)
    invoice(purchase_order)&.tds_amount&.value
  end

  def invoice_total_amount(purchase_order)
    invoice(purchase_order)&.net_amount&.value
  end

  def invoice_total_amount_after_tds(purchase_order)
    invoice_amount = invoice_total_amount(purchase_order)
    tds_amount = invoice_tds_amount(purchase_order) || 0
    if invoice_amount
      invoice_amount - tds_amount
    end
  end

  def invoice_payable_amount(purchase_order)

  end

  def invoice_line_items_count(purchase_order)

  end

  def invoice_purchase_address(purchase_order)

  end

  def invoice_delivery_address(purchase_order)

  end

  def invoice_custom_fields(purchase_order)
    # todo
  end

  protected

  def invoice(purchase_order)
    purchase_order.procurement&.invoices&.last
  end

  # def purchase_order(purchase_order)
  #   procurement&.purchase_order
  # end

end