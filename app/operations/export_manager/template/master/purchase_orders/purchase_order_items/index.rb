class ExportManager::Template::Master::PurchaseOrders::PurchaseOrderItems::Index < ExportManager::Builders::Template

  label 'Spreadsheet (Line Items)'
  description 'Purchase Orders Export (Line Items)'
  export_format 'xls'
  resource 'purchase_order_items'
  subscribe 'purchase_order_items'
  default true

  attribute :description, template: '{{ record.description }}'
  attribute :comment, template: '{{ record.comment }}'
  attribute :category, template: '{{ record.inventory_line_item.category.name }}'
  attribute :gl_code, template: '{{ record.category.gl_code }}'
  attribute :hsn_sac, template: '{{ record.hsn_sac }}'
  attribute :quantity, template: '{{ record.quantity }}'
  attribute :rate, template: '{{ record.rate }}'
  attribute :discount, template: '{{ record.discount }}'
  attribute :discount_amount, template: '{{ record.discount_amount.value }}'
  attribute :tax, template: '{{ record.tax_rate.rate }}'
  attribute :tax_amount, template: '{{ record.tax_amount.value }}'
  attribute :total_amount, template: '{{ record.total_amount.value }}'

  attribute :procurement_name, template: '{{ record.purchase_order.name }}'
  attribute :po_number, template: '{{ record.purchase_order.po_number }}'
  attribute :po_creation_date, template: "{{ record.purchase_order.created_at | date: '%d-%b-%Y' }}"
  attribute :po_closed_date, template: "{{ record.purchase_order.closed_at | date: '%d-%b-%Y' }}"
  attribute :created_by, template: '{{ record.purchase_order.user.name }}'
  attribute :policy, template: '{{ record.purchase_order.policy.name }}'
  attribute :vendor_name, template: '{{ record.purchase_order.vendor.display_name }}'
  attribute :vendor_business_name, template: '{{ record.purchase_order.vendor.business_name }}'
  attribute :vendor_mobile_number, template: '{{ record.purchase_order.vendor.mobile_number }}'
  attribute :vendor_state_code, template: '{{ record.purchase_order.vendor.state_code.code }}'
  attribute :vendor_gstin, template: '{{ record.purchase_order.gstin_location.gstin }}'
  attribute :vendor_pan, template: '{{ record.purchase_order.vendor.pan }}'
  attribute :vendor_tds_rate, template: ''
  attribute :vendor_tds_description, template: ''
  attribute :vendor_type, template: '{{ record.purchase_order.vendor.vendor_type.name }}'
  attribute :vendor_description, template: '{{ record.purchase_order.vendor.description }}'
  attribute :vendor_address, template: '{{ record.purchase_order.vendor.address }}'
  attribute :approval_pending_level_number, template: '{{ record.purchase_order.controlling_level.level_number }}'
  attribute :approval_pending_level_name, template: '{{ record.purchase_order.controlling_level.name }}'
  attribute :approval_pending_reviewers, template: '{{ record.purchase_order.get_reviewers_names }}'
  attribute :approved_reviewers, template: '{{ record.purchase_order.approved_reviewers_names }}'

  attribute :department, template: '{{ record.purchase_order.department.name }}'
  attribute :sub_department, template: '{{ record.purchase_order.sub_department.name }}'
  attribute :cost_center, template: '{{ record.purchase_order.cost_center.name }}'
  attribute :po_status, template: '{{ record.purchase_order.status.name }}'
  attribute :po_payment_term, template: '{{ record.purchase_order.payment_term.name }}'
  attribute :po_delivery_date, template: "{{ record.purchase_order.delivery_date | date: '%d-%b-%Y' }}"
  attribute :is_po_approved, template: '{% if record.purchase_order.is_approved %}Yes{% else %}No{% endif %}'
  attribute :po_approved_on, template: "{{ record.purchase_order.approved_at | date: '%d-%b-%Y' }}"
  attribute :po_base_value, template: '{{ record.purchase_order.total_before_tax.value }}'
  attribute :po_cgst, template: '{{ record.purchase_order.cgst_amount }}'
  attribute :po_sgst, template: '{{ record.purchase_order.sgst_amount }}'
  attribute :po_igst, template: '{{ record.purchase_order.igst_amount }}'
  attribute :po_purchase_address, template: '{{ record.purchase_order.billing_address }}'
  attribute :po_delivery_address, template: '{{ record.purchase_order.shipping_address }}'
end