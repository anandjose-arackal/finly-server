class ExportManager::Master::PurchaseOrders::PurchaseOrderItems::Index < ExportManager::Builders::Spreadsheet


  label 'Spreadsheet (Line Items)'
  description 'Purchase Orders Export (Line Items)'
  configurable true
  system :vp
  screen ['purchase_orders.index', 'po_advances.index']
  handle :purchase_order_items
  validate :input

  section :item_details do
    attribute :description
    attribute :comment
    attribute :category
    attribute :gl_code
    attribute :hsn_sac
    attribute :quantity
    attribute :rate
    attribute :discount
    attribute :discount_amount
    attribute :tax
    attribute :tax_amount
    attribute :total_amount
  end

  section :po_details do
    attribute :procurement_name
    attribute :po_number
    attribute :po_creation_date
    attribute :po_closed_date
    attribute :created_by
    attribute :policy
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
    attribute :approval_pending_level_number
    attribute :approval_pending_level_name
    attribute :approval_pending_reviewers
    attribute :approved_reviewers

    attribute :department
    attribute :sub_department
    attribute :cost_center
    attribute :po_status
    attribute :po_payment_term
    attribute :po_delivery_date
    attribute :is_po_approved
    attribute :po_approved_on
    attribute :po_base_value
    attribute :po_cgst
    attribute :po_sgst
    attribute :po_igst
    attribute :po_purchase_address
    attribute :po_delivery_address
  end

  section :custom_fields do
    attribute :custom_fields, dynamic: true
  end

  def input
    po = resolve 'purchase_orders.default'
    PurchaseOrderItem.where "purchase_order_id in (#{po.select('id').to_sql})"
  end

  def procurement_name(item)
    procurement(item)&.name
  end

  def po_number(item)
    purchase_order(item)&.po_number
  end

  def po_creation_date(item)
    purchase_order(item)&.created_at&.strftime "%d-%b-%Y"
  end

  def po_closed_date(item)
    purchase_order(item).trails&.find_by(action_id: TrailAction.id_for(:close))&.created_at&.strftime("%d-%b-%Y")
  end

  def created_by(item)
    purchase_order(item)&.user&.name
  end

  def description(item)
    item.description
  end

  def comment(item)
    item.comment
  end

  def category(item)
    item&.category&.name
  end

  def gl_code(item)
    item&.category&.gl_code
  end

  def hsn_sac(item)
    item.hsn_sac
  end

  def quantity(item)
    item.quantity
  end

  def rate(item)
    item.rate
  end

  def tax(item)
    item.tax_rate&.rate || 0
  end

  def tax_amount(item)
    value = item.tax_amount&.value || 0
    precision_value(value)
  end

  def discount(item)
    item.discount || 0
  end

  def discount_amount(item)
    value = item.discount_amount&.value || 0
    precision_value(value)
  end

  def total_amount(item)
    value = item.total_amount&.value || 0
    precision_value(value)
  end

  def policy(item)
    item&.purchase_order&.policy&.name
  end

  # PURCHASEORDER DETAILS
  # 

  def vendor_name(item)
    purchase_order(item)&.procurement.vendor&.display_name
  end

  def vendor_business_name(item)
    purchase_order(item)&.procurement.vendor&.business_name
  end

  def vendor_mobile_number(item)
    purchase_order(item)&.procurement.vendor&.mobile_number
  end

  def vendor_state_code(item)
    sc = purchase_order(item)&.procurement.vendor&.state_code&.state_code
    (sc.present?) ? (sprintf '%02d', sc) : ''
  end

  def vendor_pan(item)
    purchase_order(item)&.procurement.vendor&.pan
  end

  def vendor_gstin(item)
    purchase_order(item)&.gstin_location&.gstin
  end

  def vendor_tds_rate(item)
    purchase_order(item)&.vendor&.tds_rates_list&.tds
  end

  def vendor_tds_description(item)
    purchase_order(item)&.vendor&.tds_rates_list&.name
  end

  def vendor_type(item)
    purchase_order(item)&.procurement.vendor&.vendor_type&.name
  end

  def vendor_description(item)
    purchase_order(item)&.procurement.vendor&.description
  end

  def vendor_address(item)
    purchase_order(item)&.procurement.vendor&.address
  end

  def approval_pending_level_number(item)
    purchase_order(item)&.controlling_level&.level_number
  end

  def approval_pending_level_name(item)
    purchase_order(item)&.controlling_level&.name
  end

  def approval_pending_reviewers(item)
    purchase_order(item)&.get_reviewers&.map(&:name)&.join(", ")
  end

  def approved_reviewers(item)
    purchase_order(item)&.dlrms&.where(action_id: TrailAction.id_for(:approve))&.includes(:reviewer)&.map { |dlr| dlr.reviewer.name }&.join(" ,")
  end

  def department(item)
    purchase_order(item).procurement.type_entity&.department&.name
  end

  def sub_department(item)
    purchase_order(item).procurement.type_entity&.sub_department&.name
  end

  def cost_center(item)
    purchase_order(item).procurement.type_entity&.cost_center&.name
  end

  def po_status(item)
    purchase_order(item).procurement.purchase_order&.status&.name&.humanize
  end

  def po_payment_term(item)
    purchase_order(item)&.payment_term&.name
  end

  def po_delivery_date(item)
    purchase_order(item)&.delivery_date&.strftime("%d-%b-%Y")
  end

  def is_po_approved(item)
    PurchaseOrderStatus.ids_for(:approved, :auto_approved, :closed, :sent_to_vendor, :vendor_confirmed).include?(purchase_order(item)&.purchase_order_status_id) ? 'Yes' : 'No'
  end

  def po_approved_on(item)
    purchase_order(item)&.approved_at&.strftime("%d-%b-%Y")
  end

  def po_base_value(item)
    precision_value purchase_order(item)&.total_before_tax&.value
  end

  def po_cgst(item)
    if purchase_order(item)&.gst_type&.cgst?
      value = purchase_order(item)&.tax_amount&.value
      if value
        return precision_value (value / 2)
      end
    end
  end

  def po_sgst(item)
    po_cgst(item)
  end

  def po_igst(item)
    if purchase_order(item)&.gst_type&.igst?
      precision_value purchase_order(item)&.tax_amount&.value
    end
  end

  def po_purchase_address(item)
    purchase_order(item)&.billing_address
  end

  def po_delivery_address(item)
    purchase_order(item)&.shipping_address
  end

  def custom_fields(row, item)
    purchase_order(item).custom_fields.includes(:field_configuration).each do |custom_field|
      row.add(custom_field.field_configuration.field_name, custom_field.string_value)
    end
  end

  protected

  def purchase_order(item)
    item&.purchase_order
  end

  def procurement(item)
    purchase_order(item)&.procurement
  end

  def inventory_line_item(item)
    item&.inventory_line_item
  end


end