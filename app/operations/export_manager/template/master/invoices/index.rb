class ExportManager::Template::Master::Invoices::Index < ExportManager::Builders::Template

  label 'Spreadsheet'
  description 'Invoices Export'
  export_format 'csv'
  resource 'invoice_line_items'
  subscribe 'invoice_line_items'
  default true

  attribute :finly_ref_no, template: '{{ record.invoice.invoice_id }}'
  attribute :po_number, template: '{{ record.invoice.po_number }}'
  attribute :invoice_type, template: '{{ record.invoice.invoice_type.name }}'
  attribute :invoice_no, template: '{{ record.invoice.invoice_number }}'
  attribute :invoice_date, template: "{{ record.invoice.date | date: '%d-%b-%Y' }}"
  attribute :created_by, template: '{{ record.invoice.created_by.name }}'
  attribute :created_at, template: "{{ record.invoice.created_at | date: '%d-%b-%Y' }}"
  attribute :po_date, template: "{{ record.po_date | date: '%d-%b-%Y' }}"
  attribute :transaction_period_from, template: "{{ record.invoice.transaction_service_period_from | date: '%d-%b-%Y' }}"
  attribute :transaction_period_to, template: "{{ record.invoice.transaction_service_period_to | date: '%d-%b-%Y' }}"
  attribute :is_invoice_approved, template: '{% if record.invoice.is_approved %}Yes{% else %}No{% endif %}'
  attribute :invoice_status, template: '{{ record.invoice.status.name }}'
  attribute :policy, template: '{{ record.invoice.policy.name }}'
  attribute :narration, template: '{{ record.invoice.narration }}'
  attribute :invoice_amount, template: '{{ record.invoice.invoice_amount }}'
  attribute :advance_amount, template: '{{ record.invoice.invoice_advance_amount }}'
  attribute :invoice_net_payable_amount, template: '{{ record.invoice.balance_due_value }}'
  attribute :approvers, template: '{{ record.invoice.approvers }}'
  attribute :finance_approved_date, template: "{{ record.invoice.approved_at | date: '%d-%b-%Y' }}"
  attribute :due_date, template: "{{ record.invoice.due_date | date: '%d-%b-%Y' }}"
  attribute :invoice_discount, template: '{{ record.invoice.discount_amount_value }}'
  attribute :attachments, template: '{{ record.invoice.attachments }}'
  attribute :approval_pending_reviewers, template: '{{ record.invoice.approval_pending_reviewers }}'

  attribute :vendor_name, template: '{{ record.invoice.vendor.display_name }}'
  attribute :vendor_ref_no, template: '{{ record.invoice.vendor.vendor_id }}'
  attribute :vendor_gstin, template: '{{ record.invoice.gstin_location.gstin }}'
  attribute :vendor_state, template: '{{ record.invoice.gstin_location.state.name }}'
  attribute :billing_location, template: '{{ record.invoice.billing_location.name }}'
  attribute :shipping_location, template: '{{ record.invoice.shipping_location.name }}'

  attribute :tds_nature, template: '{{ record.tds_nature }}'
  attribute :tds_percentage, template: '{{ record.tds_percentage }}'
  attribute :tds_amount, template: '{{ record.tds_amount }}'
  attribute :rcm_enabled, template: '{% if record.invoice.rcm_enabled %}Yes{% endif %}'

  attribute :category, template: '{{ record.category.name}}'
  attribute :quantity, template: '{{ record.quantity }}'
  attribute :rate, template: '{{ record.rate }}'
  attribute :location_name, template: '{{ record.invoice.billing_location.name }}'
  attribute :location_code, template: '{{ record.invoice.billing_location.location_code }}'
  attribute :department_name, template: '{{ record.department.name }}'
  attribute :department_code, template: '{{ record.department.department_code }}'
  attribute :gst_group, template: '{{ record.tax_rate.name }}'
  attribute :hsn_sac, template: '{{ record.hsn_sac }}'
  attribute :line_item_discount, template: '{{ record.discount_amount_value }}'
  attribute :line_item_sgst, template: '{{ record.sgst_amount }}'
  attribute :line_item_cgst, template: '{{ record.cgst_amount }}'
  attribute :line_item_igst, template: '{{ record.igst_amount }}'
  attribute :cost_center, template: '{{ record.cost_center.name }}'
  attribute :item_code, template: '{{ record.item_code }}'
  attribute :description, template: '{{ record.description }}'
  attribute :unit_of_measurement, template: '{{ record.unit_of_measurement }}'
  attribute :total_amount, template: '{{ record.total_amount }}'
  attribute :tax_amount, template: '{{ record.tax_amount_value }}'
  attribute :tax_rate, template: '{{ record.tax_rate.rate }}'
  attribute :tax_type, template: '{{ record.tax_rate.name }}'
end
