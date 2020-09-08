class ExportManager::Master::PurchaseOrders::Index < ExportManager::Builders::Template

  label 'Spreadsheet'
  description 'Purchase Orders Export'
  export_format 'csv'
  resource 'purchase_orders'
  subscribe 'purchase_orders'

  attribute :procurement_name, template: '{{ record.name }}'
  attribute :vendor_name, template: '{{ record.vendor.display_name }}'
  attribute :vendor_business_name, template: '{{ record.vendor.business_name }}'
  attribute :vendor_mobile_number, template: '{{ record.vendor.mobile_number }}'
  attribute :vendor_state_code, template: '{{ record.vendor.state_code.code }}'
  attribute :vendor_gstin, template: '{{ record.gstin_location.gstin }}'
  attribute :vendor_pan, template: '{{ record.vendor.pan }}'
  attribute :vendor_tds_rate, template: ''
  attribute :vendor_tds_description, template: ''
  attribute :vendor_type, template: '{{ record.vendor.vendor_type.name }}'
  attribute :vendor_description, template: '{{ record.vendor.description }}'
  attribute :vendor_address, template: '{{ record.vendor.address }}'
  attribute :vendor_custom_fields, template: ''
  attribute :approval_pending_level_number, template: '{{ record.controlling_level.level_number }}'
  attribute :approval_pending_level_name, template: '{{ record.controlling_level.name }}'
  attribute :approval_pending_reviewers, template: '{{ record.get_reviewers_names }}'
  attribute :approved_reviewers, template: '{{ record.approved_reviewers_names }}'
  attribute :policy, template: '{{ record.policy.name }}'
  attribute :department, template: '{{ record.department.name }}'
  attribute :sub_department, template: '{{ record.sub_department.name }}'
  attribute :cost_center, template: '{{ record.cost_center.name }}'
  ############################### PR Details ################################
  attribute :pr_number, template: '{{ record.purchase_request.request_id }}'
  attribute :pr_created_by, template: '{{ record.purchase_request.created_by.name }}'
  attribute :pr_date, template: "{{ record.purchase_request.created_at | date: '%d-%b-%Y' }}"
  ############################### PR Details ################################
  attribute :po_user, template: '{{ record.user.name }}'
  attribute :po_status, template: '{{ record.status.name }}'
  attribute :po_number, template: '{{ record.po_number }}'
  attribute :po_payment_term, template: '{{ record.payment_term.name }}'
  attribute :po_creation_date, template: "{{ record.created_at | date: '%d-%b-%Y' }}"
  attribute :po_closed_date, template: "{{ record.closed_at | date: '%d-%b-%Y' }}"
  attribute :po_delivery_date, template: "{{ record.delivery_date | date: '%d-%b-%Y' }}"
  attribute :po_submitted_on, template: "{{ record.submitted_at | date: '%d-%b-%Y' }}"
  attribute :is_po_approved, template: '{% if record.is_approved %}Yes{% else %}No{% endif %}'
  attribute :po_approved_on, template: ''
  attribute :po_sent_on, template: ''
  attribute :po_base_value, template: '{{ record.total_before_tax.value }}'
  attribute :po_cgst, template: '{{ record.cgst_amount }}'
  attribute :po_sgst, template: '{{ record.sgst_amount }}'
  attribute :po_igst, template: '{{ record.igst_amount }}'
  attribute :po_line_items_count, template: ''
  attribute :po_purchase_address, template: '{{ record.billing_address }}'
  attribute :po_delivery_address, template: '{{ record.shipping_address }}'
  attribute :po_custom_fields, template: ''
  attribute :inwards_status, template: ''
  attribute :last_inward_received_on, template: ''
  attribute :invoice_number, template: '{{ record.invoice.invoice_number }}'
  attribute :invoice_id, template: '{{ record.invoice.invoice_id }}'
  attribute :invoice_payment_term, template: ''
  attribute :invoice_delivery_date, template: ''
  attribute :invoice_submitted_on, template: ''
  attribute :invoice_approved_on, template: ''
  attribute :is_invoice_approved, template: '{% if record.invoice.is_approved %}Yes{% else %}No{% endif %}'
  attribute :po_advance_status, template: '{{ record.advance_amount_status.name }}'
  attribute :advance_amount, template: '{{ record.advance_amount.value }}'
  attribute :advance_tds_amount, template: '{{ record.advance_tds_amount.value }}'
  attribute :advance_tds_slab, template: '{{ record.advance_tds_slab.name }}'
  attribute :invoice_sent_on, template: ''
  attribute :invoice_cgst, template: '{{ record.invoice.cgst_amount }}'
  attribute :invoice_sgst, template: '{{ record.invoice.sgst_amount }}'
  attribute :invoice_igst, template: '{{ record.invoice.igst_amount }}'
  attribute :invoice_tds_type, template: '{{ record.invoice.tds_slab.name }}'
  attribute :invoice_tds_rate, template: '{{ record.invoice.tds_rate.value }}'
  attribute :invoice_tds_amount, template: '{{ record.invoice.tds_amount.value }}'
  attribute :invoice_base_amount, template: '{{ record.invoice.item_amounts_total }}'
  attribute :invoice_discount_amount, template: '{{ record.invoice.discount_amount_value }}'
  attribute :invoice_total_amount, template: '{{ record.invoice.net_amount.value }}'
  attribute :invoice_total_amount_after_tds, template: '{{ record.invoice.net_amount.value | minus: record.invoice.tds_amount.value }}'
  attribute :invoice_payable_amount, template: ''
  attribute :invoice_line_items_count, template: ''
  attribute :invoice_purchase_address, template: ''
  attribute :invoice_delivery_address, template: ''
  attribute :invoice_custom_fields, template: ''

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

  # def procurement_name(purchase_order)
  #   purchase_order.procurement.name
  # end

  # def vendor_name(purchase_order)
  #   purchase_order.procurement.vendor&.display_name
  # end

  # def vendor_business_name(purchase_order)
  #   purchase_order.procurement.vendor&.business_name
  # end

  # def vendor_mobile_number(purchase_order)
  #   purchase_order.procurement.vendor&.mobile_number
  # end

  # def vendor_state_code(purchase_order)
  #   purchase_order.procurement.vendor&.state_code
  # end

  # def vendor_pan(purchase_order)
  #   purchase_order.procurement.vendor&.pan
  # end

  # def vendor_gstin(purchase_order)
  #   purchase_order.gstin_location&.gstin
  # end

  # def approval_pending_level_number(purchase_order)
  #   purchase_order&.controlling_level&.level_number
  # end

  # def approval_pending_level_name(purchase_order)
  #   purchase_order&.controlling_level&.name
  # end

  # def approval_pending_reviewers(purchase_order)
  #   purchase_order&.get_reviewers&.map(&:name)&.join(", ")
  # end

  # def approved_reviewers(purchase_order)
  #   purchase_order&.dlrms&.where(action_id: TrailAction.id_for(:approve))&.includes(:reviewer)&.map {|dlr| dlr.reviewer.name}&.join(" ,")
  # end

  # def vendor_tds_rate(purchase_order)
  #   # todo
  # end

  # def vendor_tds_description(purchase_order)
  #   # todo
  # end

  # def vendor_type(purchase_order)
  #   purchase_order.procurement.vendor&.vendor_type&.name
  # end

  # def vendor_description(purchase_order)
  #   purchase_order.procurement.vendor&.description
  # end

  # def vendor_address(purchase_order)
  #   purchase_order.procurement.vendor&.address
  # end

  # def vendor_custom_fields(purchase_order)
  #   # todo
  # end

  # def policy(purchase_order)
  #   purchase_order.procurement.type_entity&.policy&.name
  # end

  # def department(purchase_order)
  #   purchase_order.procurement.type_entity&.department&.name
  # end

  # def sub_department(purchase_order)
  #   purchase_order.procurement.type_entity&.sub_department&.name
  # end

  # def cost_center(purchase_order)
  #   purchase_order.procurement.type_entity&.cost_center&.name
  # end

  # def po_user(purchase_order)
  #   if purchase_order.procurement.purchase_order.present?
  #     purchase_order&.user&.name
  #   end
  # end

  # def po_status(purchase_order)
  #   purchase_order.procurement.purchase_order&.status&.name&.humanize
  # end

  # def po_number(purchase_order)
  #   purchase_order&.po_number
  # end

  # def po_payment_term(purchase_order)
  #   purchase_order&.payment_term&.name
  # end

  # def po_delivery_date(purchase_order)
  #   purchase_order&.delivery_date&.strftime("%d-%b-%Y")
  # end

  # def po_creation_date(purchase_order)
  #   purchase_order&.created_at&.strftime("%d-%b-%Y")
  # end

  # def po_closed_date(purchase_order)
  #   purchase_order.trails&.find_by(action_id: TrailAction.id_for(:close))&.created_at&.strftime("%d-%b-%Y")
  # end

  # def po_submitted_on(purchase_order)
  #   # todo
  #   purchase_order.trails&.where(action_id: TrailAction.id_for(:submit))&.last&.created_at&.strftime("%d-%b-%Y")
  # end

  # def is_po_approved(purchase_order)
  #   PurchaseOrderStatus.ids_for(:approved, :auto_approved, :closed, :sent_to_vendor, :vendor_confirmed).include?(purchase_order&.purchase_order_status_id) ? 'Yes' : 'No'
  # end

  # def po_approved_on(purchase_order)
  #   # todo
  # end

  # def po_sent_on(purchase_order)
  #   # todo
  # end

  # def po_base_value(purchase_order)
  #   purchase_order&.total_before_tax&.value
  # end

  # def po_cgst(purchase_order)
  #   if purchase_order&.gst_type&.cgst?
  #     value = purchase_order&.tax_amount&.value
  #     if value
  #       return value / 2
  #     end
  #   end
  # end

  # def po_sgst(purchase_order)
  #   po_cgst(purchase_order)
  # end

  # def po_igst(purchase_order)
  #   if purchase_order&.gst_type&.igst?
  #     purchase_order&.tax_amount&.value
  #   end
  # end

  # def po_line_items_count(purchase_order)
  #   # todo
  # end

  # def po_purchase_address(purchase_order)
  #   purchase_order&.billing_address
  # end

  # def po_delivery_address(purchase_order)
  #   purchase_order&.shipping_address
  # end

  # def po_custom_fields(purchase_order)
  #   # todo
  # end

  # def inwards_status(purchase_order)
  #   # todo
  # end

  # def last_inward_received_on(purchase_order)
  #   # todo
  # end

  # def po_advance_status(purchase_order)
  #   purchase_order&.advance_amount_status&.name&.humanize
  # end

  # def advance_amount(purchase_order)
  #   purchase_order&.advance_amount&.value
  # end

  # def advance_tds_amount(purchase_order)
  #   purchase_order&.advance_tds_amount&.value
  # end

  # def advance_tds_slab(purchase_order)
  #   purchase_order&.advance_tds_slab&.name
  # end

  # def invoice_number(purchase_order)
  #   purchase_order.procurement.invoices&.first&.invoice_number
  # end

  # def invoice_id(purchase_order)
  #   purchase_order.procurement.invoices.first&.invoice_id
  # end

  # def invoice_payment_term(purchase_order)
  #   # todo
  # end

  # def invoice_delivery_date(purchase_order)

  # end

  # def invoice_submitted_on(purchase_order)
  #   # todo
  # end

  # def invoice_approved_on(purchase_order)
  #   # todo
  # end

  # def is_invoice_approved(purchase_order)
  #   InwardInvoiceStatus.ids_for(:partially_paid, :paid, :approved, :rejected, :auto_approved, :closed).include?(invoice(purchase_order)&.invoice_status_id) ? 'Yes' : 'No'
  # end

  # def invoice_sent_on(purchase_order)

  # end

  # def invoice_cgst(purchase_order)
  #   if invoice(purchase_order)&.gst_type&.cgst?
  #     value = invoice(purchase_order)&.tax_amount&.value
  #     if value
  #       return value / 2
  #     end
  #   end
  # end

  # def invoice_sgst(purchase_order)
  #   invoice_cgst(purchase_order)
  # end

  # def invoice_igst(purchase_order)
  #   if invoice(purchase_order)&.gst_type&.igst?
  #     invoice(purchase_order)&.tax_amount&.value
  #   end
  # end

  # def invoice_tds_type(purchase_order)
  #   invoice(purchase_order)&.tds_slab&.name
  # end

  # def invoice_tds_rate(purchase_order)
  #   invoice(purchase_order)&.tds_slab&.tds
  # end

  # def invoice_base_amount(purchase_order)
  #   invoice(purchase_order)&.item_amounts_total
  # end

  # def invoice_discount_amount(purchase_order)
  #   invoice(purchase_order)&.discount_amount&.value
  # end

  # def invoice_tds_amount(purchase_order)
  #   invoice(purchase_order)&.tds_amount&.value
  # end

  # def invoice_total_amount(purchase_order)
  #   invoice(purchase_order)&.net_amount&.value
  # end

  # def invoice_total_amount_after_tds(purchase_order)
  #   invoice_amount = invoice_total_amount(purchase_order)
  #   tds_amount = invoice_tds_amount(purchase_order) || 0
  #   if invoice_amount
  #     invoice_amount - tds_amount
  #   end
  # end

  # def invoice_payable_amount(purchase_order)

  # end

  # def invoice_line_items_count(purchase_order)

  # end

  # def invoice_purchase_address(purchase_order)

  # end

  # def invoice_delivery_address(purchase_order)

  # end

  # def invoice_custom_fields(purchase_order)
  #   # todo
  # end

  # def pr_number purchase_order
  #   request = purchase_order.purchase_request_items.first&.purchase_request
  #   request.present? ? request&.order_number : ''
  # end

  # def pr_created_by purchase_order
  #   request = purchase_order.purchase_request_items.first&.purchase_request
  #   request.present? ? request&.creator&.name : ''
  # end

  # def pr_date purchase_order
  #   request = purchase_order.purchase_request_items.first&.purchase_request
  #   request.present? ? request&.created_at&.strftime("%d-%b-%Y") : ''
  # end

  # protected

  # def invoice(purchase_order)
  #   purchase_order.procurement&.invoices&.last
  # end

  # def purchase_order(purchase_order)
  #   procurement&.purchase_order
  # end
end