class ExportManager::Template::Master::Invoices::TdsExport < ExportManager::Builders::Template

  label 'Tds Export'
  description 'Tds Export'
  export_format 'xls'
  resource 'invoices'
  subscribe 'invoices'
  default true

  query Hash({
    qs: {
      invoice_status_id_eq_any: InwardInvoiceStatus.ids_for(%i[partially_paid paid])
    }
  })

  roles [:admin, :finance_manager]

  custom_fields :invoice, template_prefix: 'record'
  form_custom_fields :invoices, template_prefix: 'record'

  attribute :invoice_number, template: '{{ record.invoice_number }}'
  attribute :finly_ref_no, template: '{{ record.invoice_id }}'
  attribute :invoice_date, template: "{{ record.date | date: '%d-%b-%y' }}"
  attribute :invoice_status, template: '{{ record.status.name }}'
  attribute :invoice_type, template: '{{ record.invoice_type.name }}'
  attribute :created_by, template: '{{ record.created_by.name }}'
  attribute :tds_gl_code, template: '{{ record.tds_slab.gl_code }}'
  attribute :legal_status, template: '{{ record.vendor_location.gstin_master.constitution_of_business }}'
  attribute :pan, template: '{{ record.vendor.pan }}'
  attribute :vendor_id, template: '{{ record.vendor.vendor_id }}'
  attribute :vendor_name, template: '{{ record.vendor.display_name }}'
  # attribute :payment_date
  attribute :total_invoice_amount, template: '{{ record.total_invoice_amount }}'
  attribute :invoice_base_amount, template: '{{ record.base_amount }}'
  attribute :tds_name, template: '{{ record.tds_slab.name }}'
  attribute :tds_payable, template: '{{ record.tds_rate }}'
  attribute :tds_amount, template: '{{ record.tds_amount_value }}'
  attribute :cgst_sgst_amount, template: '{{ record.cgst_amount }}'
  attribute :igst_amount, template: '{{ record.igst_amount }}'
  attribute :amount_paid, template: '{{ record.payment_amounts_total }}'


  attribute :reporting_net_total, template: '{{ record.reporting_invoice_net_total_amount }}', toggle: { if: [ NonPoInvoiceToggle, :enabled?] }
  attribute :reporting_payable_amount, template: '{{ record.reporting_invoice_balance_due | round }}', toggle: { if: [ NonPoInvoiceToggle, :enabled?] }
  attribute :conversion_rate, template: '{{ record.conversion_rate }}', toggle: { if: [ NonPoInvoiceToggle, :enabled?] }
  attribute :base_currency, template: '{{ record.base_currency_code }}', toggle: { if: [ NonPoInvoiceToggle, :enabled?] }
  attribute :reporting_currency, template: '{{ record.reporting_currency_code }}', toggle: { if: [ NonPoInvoiceToggle, :enabled?] }
end
