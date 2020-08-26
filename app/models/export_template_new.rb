# == Schema Information
#
# Table name: export_template_news
#
#  id                    :bigint           not null, primary key
#  name                  :string(255)      not null
#  description           :text(65535)
#  export_format         :string(255)      not null
#  resource              :string(255)      not null
#  template              :text(4294967295)
#  query                 :text(4294967295)
#  active                :boolean          default(TRUE)
#  personal              :boolean
#  company_id            :integer
#  created_by_id         :integer
#  deleted_at            :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class ExportTemplateNew < ApplicationRecord
  belongs_to :company
  belongs_to :created_by, class_name: 'User'

  has_many :role_mappings, class_name: 'ExportTemplateUserRoleMapping', foreign_key: 'template_id', dependent: :destroy
  has_many :user_roles, through: :role_mappings, dependent: :destroy

  # TODO: update seeding to add default templates for all companies and add roles too
  DEFAULT_TEMPLATES = [
    {
      "name": 'GST Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'invoice_line_items',
      "created_by_id": 1,
      "company_id": 1,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Invoice number', "value": '{{ record.invoice.invoice_number }}' },
            { "label": 'Finly ref no.', "value": '{{ record.invoice.invoice_id }}' },
            { "label": 'Finly approved date', "value": "{{ record.invoice.approved_at | date: '%d-%b-%Y' }}" },
            { "label": 'Vendor gstin', "value": '{{ record.invoice.gstin_location.gstin }}' },
            { "label": 'Billing location', "value": '{{ record.invoice.billing_location.name }}' },
            { "label": 'Shipping location', "value": '{{ record.invoice.shipping_location.name }}' },
            { "label": 'Gl code', "value": '{{ record.category.gl_code }}' },
            { "label": 'Description', "value": '{{ record.description }}' },
            { "label": 'Invoice net payable amount', "value": '{{ record.invoice.balance_due_value }}' },
            { "label": 'Invoice base amount', "value": '{{ record.invoice.base_amount }}' },
            { "label": 'Total tax', "value": '{{ record.tax_amount.value }}' },
            { "label": 'Item rate', "value": '{{ record.rate }}' },
            { "label": 'Item igst amount', "value": '{{ record.igst_amount }}' },
            { "label": 'Item cgst amount', "value": '{{ record.cgst_amount }}' },
            { "label": 'Item sgst amount', "value": '{{ record.sgst_amount }}' },
            { "label": 'Item igst', "value": '{{ record.igst }}' },
            { "label": 'Item cgst', "value": '{{ record.cgst }}' },
            { "label": 'Item sgst', "value": '{{ record.sgst }}' },
            { "label": 'Igst account number', "value": '{{ record.tax_rate.igst_account_number }}' },
            { "label": 'Cgst account number', "value": '{{ record.tax_rate.cgst_account_number }}' },
            { "label": 'Sgst account number', "value": '{{ record.tax_rate.sgst_account_number }}' },
            { "label": 'Hsn sac', "value": '{{ record.hsn_sac }}' },
            { "label": 'Reverse charge', "value": '0' },
            { "label": 'Reverse charge tax gl account', "value": 'N' },
            { "label": 'Calculate tax for rct', "value": 'N' },
            { "label": 'Invoice status', "value": '{{ record.invoice.status.name }}' },
            { "label": 'Itc qualified', "value": '{{ record.itc_qualified }}' },
            { "label": 'Country', "value": '{{ record.country }}' },
            { "label": 'Vendor name', "value": '{{ record.invoice.vendor.business_name }}' },
            { "label": 'Department code', "value": '{{ record.department.department_code }}' }
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'TDS Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'invoices',
      "created_by_id": 1,
      "company_id": 1,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Invoice number', "value": '{{ record.invoice_number }}' },
            { "label": 'Finly ref no.', "value": '{{ record.invoice_id }}' },
            { "label": 'Invoice Date', "value": "{{ record.date | date: '%d-%b-%y' }}" },
            { "label": 'Invoice Status', "value": '{{ record.status.name }}' },
            { "label": 'Invoice Type', "value": '{{ record.invoice_type.name }}' },
            { "label": 'Created by', "value": '{{ record.created_by.name }}' },
            { "label": 'TDS GL Code', "value": '{{ record.tds_slab.gl_code }}' },
            { "label": 'Legal Status', "value": '{{ record.vendor_location.gstin_master.constitution_of_business }}' },
            { "label": 'PAN', "value": '{{ record.vendor.pan }}' },
            { "label": 'Vendor ID', "value": '{{ record.vendor.vendor_id }}' },
            { "label": 'Vendor Name', "value": '{{ record.vendor.display_name }}' },
            { "label": 'Total Invoice Amount', "value": '{{ record.total_invoice_amount }}' },
            { "label": 'Invoice Base Amount', "value": '{{ record.base_amount }}' },
            { "label": 'TDS Name', "value": '{{ record.tds_slab.name }}' },
            { "label": 'TDS Payable', "value": '{{ record.tds_rate }}' },
            { "label": 'TDS Amount', "value": '{{ record.tds_amount_value }}' },
            { "label": 'CGST SGST Amount', "value": '{{ record.cgst_amount }}' },
            { "label": 'IGST Amount', "value": '{{ record.igst_amount }}' },
            { "label": 'Amount Paid', "value": '{{ record.payment_amounts_total }}' }
          ]
        }
      ),
      "query": JSON.generate(
        {
          "qs": {
            "invoice_status_id_eq_any": InwardInvoiceStatus.ids_for([:partially_paid, :paid])
          }
        }
      ),
      "personal": false
    },
    {
      "name": 'Spreadsheet',
      "description": '',
      "export_format": 'csv',
      "resource": 'invoice_line_items',
      "created_by_id": 1,
      "company_id": 1,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Finly ref no.', "value": '{{ record.invoice.invoice_id }}' },
            { "label": 'PO number', "value": '{{ record.invoice.po_number }}' },
            { "label": 'Invoice Type', "value": '{{ record.invoice.invoice_type.name }}' },
            { "label": 'Invoice number', "value": '{{ record.invoice.invoice_number }}' },
            { "label": 'Invoice Date', "value": "{{ record.invoice.date | date: '%d-%b-%Y' }}" },
            { "label": 'Created by', "value": '{{ record.invoice.created_by.name }}' },
            { "label": 'Created at', "value": "{{ record.invoice.created_at | date: '%d-%b-%Y' }}" },
            { "label": 'PO date', "value": "{{ record.po_date | date: '%d-%b-%Y' }}" },
            { "label": 'Transaction period from', "value": "{{ record.invoice.transaction_service_period_from | date: '%d-%b-%Y' }}" },
            { "label": 'Transaction period to', "value": "{{ record.invoice.transaction_service_period_to | date: '%d-%b-%Y' }}" },
            { "label": 'Is invoice approved?', "value": '{% if record.invoice.is_approved %}Yes{% else %}No{% endif %}' },
            { "label": 'Invoice Status', "value": '{{ record.invoice.status.name }}' },
            { "label": 'Policy', "value": '{{ record.invoice.policy.name }}' },
            { "label": 'Narration', "value": '{{ record.invoice.narration }}' },
            { "label": 'Invoice Amount', "value": '{{ record.invoice.invoice_amount }}' },
            { "label": 'Advance Amount', "value": '{{ record.invoice.invoice_advance_amount }}' },
            { "label": 'Invoice Net Payable Amount', "value": '{{ record.invoice.balance_due_value }}' },
            { "label": 'Approvers', "value": '{{ record.invoice.approvers }}' },
            { "label": 'Finance Approved Date', "value": "{{ record.invoice.approved_at | date: '%d-%b-%Y' }}" },
            { "label": 'Due Date', "value": "{{ record.invoice.due_date | date: '%d-%b-%Y' }}" },
            { "label": 'Invoice Discount', "value": '{{ record.invoice.discount_amount_value }}' },
            { "label": 'Attachments', "value": '{{ record.invoice.attachments }}' },
            { "label": 'Approval Pending Reviewers', "value": '{{ record.invoice.approval_pending_reviewers }}' },
            { "label": 'Vendor Name', "value": '{{ record.invoice.vendor.display_name }}' },
            { "label": 'Vendor Ref No.', "value": '{{ record.invoice.vendor.vendor_id }}' },
            { "label": 'Vendor gstin', "value": '{{ record.invoice.gstin_location.gstin }}' },
            { "label": 'Vendor state', "value": '{{ record.invoice.gstin_location.state.name }}' },
            { "label": 'Billing location', "value": '{{ record.invoice.billing_location.name }}' },
            { "label": 'Shipping location', "value": '{{ record.invoice.shipping_location.name }}' },
            { "label": 'TDS Nature', "value": '{{ record.tds_nature }}' },
            { "label": 'TDS Percentage', "value": '{{ record.tds_percentage }}' },
            { "label": 'TDS Amount', "value": '{{ record.tds_amount }}' },
            { "label": 'Rcm Enabled', "value": '{% if record.invoice.rcm_enabled %}Yes{% endif %}' },
            { "label": 'Category', "value": '{{ record.category.name}}' },
            { "label": 'Quantity', "value": '{{ record.quantity }}' },
            { "label": 'Rate', "value": '{{ record.rate }}' },
            { "label": 'Location Name', "value": '{{ record.invoice.billing_location.name }}' },
            { "label": 'Location Code', "value": '{{ record.invoice.billing_location.location_code }}' },
            { "label": 'Department Name', "value": '{{ record.department.name }}' },
            { "label": 'Department Code', "value": '{{ record.department.department_code }}' },
            { "label": 'GST Group', "value": '{{ record.tax_rate.name }}' },
            { "label": 'HSN SAC', "value": '{{ record.hsn_sac }}' },
            { "label": 'Line Item Discount', "value": '{{ record.discount_amount_value }}' },
            { "label": 'Line Item SGST', "value": '{{ record.sgst_amount }}' },
            { "label": 'Line Item CGST', "value": '{{ record.cgst_amount }}' },
            { "label": 'Line Item IGST', "value": '{{ record.igst_amount }}' },
            { "label": 'Cost Center', "value": '{{ record.cost_center.name }}' },
            { "label": 'Item Code', "value": '{{ record.item_code }}' },
            { "label": 'Description', "value": '{{ record.description }}' },
            { "label": 'Unit of Measurement', "value": '{{ record.unit_of_measurement }}' },
            { "label": 'Total Amount', "value": '{{ record.total_amount }}' },
            { "label": 'Tax Amount', "value": '{{ record.tax_amount_value }}' },
            { "label": 'Tax Rate', "value": '{{ record.tax_rate.rate }}' },
            { "label": 'Tax Type', "value": '{{ record.tax_rate.name }}' }
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    }
  ].freeze

  def self.seed_data
    DEFAULT_TEMPLATES.each do |template|
      ExportTemplateNew.create! template
    end
  end
end
