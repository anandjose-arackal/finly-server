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

  scope :filter_resource, -> (resource) { where resource: resource }
  scope :filter_default, -> { where default: true }

  # TODO: update seeding to add roles
  DEFAULT_TEMPLATES = [
    {
      "name": 'GST Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'invoice_line_items',
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
      "default": true,
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
      "query": JSON.generate({
        "qs": {
          "invoice_status_id_eq_any": InwardInvoiceStatus.ids_for(%i[partially_paid paid])
        }
      }),
      "personal": false
    },
    {
      "name": 'Spreadsheet',
      "description": '',
      "export_format": 'csv',
      "resource": 'invoice_line_items',
      "default": true,
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
    },
    {
      "name": 'Payment Ticket Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'payments',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Payment Order ID', "value": '{{ record.payment_order.bank_payment_request.id }}' },
            { "label": 'Payment Order Name', "value": '{{ record.payment_order.bank_payment_request.name }}' },
            { "label": 'Payment ID', "value": '{{ record.id }}' },
            { "label": 'Beneficiary Name', "value": '{{ record.receiving_account.account_owner.name }}' },
            { "label": 'Beneficiary Code', "value": '{{ record.vendor.vendor_id }}' },
            { "label": 'Beneficiary Account Name', "value": '{{ record.receiving_account.name }}' },
            { "label": 'Beneficiary Account Number', "value": '{{ record.receiving_account.account_number }}' },
            { "label": 'Beneficiary IFSC', "value": '{{ record.receiving_account.ifsc }}' },
            { "label": 'Payment Mode', "value": '{{ record.payment_mode | upcase }}' },
            { "label": 'Initiated By', "value": '{{ record.initiating_user.name }}' },
            { "label": 'Initiator Email', "value": '{{ record.initiating_user.email }}' },
            { "label": 'Payment Order Status', "value": '{{ record.payment_order.bank_payment_request.status.name }}' },
            { "label": 'Payment Order Schedule Date', "value": "{{ record.payment_order.scheduled_at | date: '%d-%b-%Y' }}" },
            { "label": 'Payment Order Submitted Date', "value": "{{ record.payment_order.bank_payment_request.submitted_at | date: '%d-%b-%Y' }}" },
            { "label": 'Payment Order Processed Date', "value": "{{ record.payment_order.processed_at | date: '%d-%b-%Y' }}" },
            { "label": 'Awaiting Action From', "value": '{{ record.payment_order.bank_payment_request.get_reviewers_names }}' },
            { "label": 'Policy', "value": '{{ record.payment_order.bank_payment_request.policy.name }}' },
            { "label": 'PO Number', "value": '{{ record.po_number }}' },
            { "label": 'Invoice Number', "value": '{{ record.invoice.invoice_number }}' },
            { "label": 'Invoice Due Date', "value": "{{ record.invoice.due_date | date: '%d-%b-%Y' }}" },
            { "label": 'Invoice Date', "value": "{{ record.invoice.date | date: '%d-%b-%Y' }}" },
            { "label": 'Invoice ID', "value": '{{ record.invoice.invoice_id }}' },
            { "label": 'Original Amount', "value": '{{ record.gross_amount.value }}' },
            { "label": 'Advance Amount', "value": '{{ record.advance_paid.value }}' },
            { "label": 'Discount', "value": '{{ record.discount.value }}' },
            { "label": 'CGST SGST Amount', "value": '{{ record.cgst_amount }}' },
            { "label": 'IGST Amount', "value": '{{ record.igst_amount }}' },
            { "label": 'TDS', "value": '{{ record.tds_amount.value }}' },
            { "label": 'Net Payable Amount', "value": '{{ record.amount.value }}' },
            { "label": 'Bank Reference Number', "value": '{{ record.utr }}' },
            { "label": 'Note', "value": '{{ record.note }}' },
            { "label": 'Payment Status', "value": '{{ record.status.name }}' },
            { "label": 'Error Message', "value": '{{ record.error_message }}' }
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'GST Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'invoice_line_items',
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
      "name": 'Spreadsheet',
      "description": 'Purchase Requests Export',
      "export_format": 'csv',
      "resource": 'purchase_requests',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Request ID', "value": '{{ record.request_id }}' },
            { "label": 'Description', "value": '{{ record.description }}' },
            { "label": 'Department', "value": '{{ record.department.name }}' },
            { "label": 'Location', "value": '{{ record.location.name }}' },
            { "label": 'Policy', "value": '{{ record.policy.name }}' },
            { "label": 'Total Items', "value": '{{ record.items.count }}' },
            { "label": 'Created by', "value": '{{ record.created_by.name }}' },
            { "label": 'Status', "value": '{{ record.status.name }}' },
            { "label": 'Amount', "value": '{{ record.total_amount.value }}' }
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'Spreadsheet',
      "description": 'Purchase Requests Export',
      "export_format": 'csv',
      "resource": 'purchase_orders',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Procurement Name', "value": '{{ record.name }}' },
            { "label": 'Vendor Name', "value": '{{ record.vendor.display_name }}' },
            { "label": 'Vendor Business Name', "value": '{{ record.vendor.business_name }}' },
            { "label": 'Vendor Mobile Number', "value": '{{ record.vendor.mobile_number }}' },
            { "label": 'Vendor State Code', "value": '{{ record.vendor.state_code.code }}' },
            { "label": 'Vendor GSTIN', "value": '{{ record.gstin_location.gstin }}' },
            { "label": 'Vendor PAN', "value": '{{ record.vendor.pan }}' },
            { "label": 'Vendor TDS Rate', "value": '' },
            { "label": 'Vendor TDS Description', "value": '' },
            { "label": 'Vendor Type', "value": '{{ record.vendor.vendor_type.name }}' },
            { "label": 'Vendor Description', "value": '{{ record.vendor.description }}' },
            { "label": 'Vendor Address', "value": '{{ record.vendor.address }}' },
            { "label": 'Vendor Custom Fields', "value": '' },
            { "label": 'Approval Pending Level Number', "value": '{{ record.controlling_level.level_number }}' },
            { "label": 'Approval Pending Level Name', "value": '{{ record.controlling_level.name }}' },
            { "label": 'Approval Pending Reviewers', "value": '{{ record.get_reviewers_names }}' },
            { "label": 'Approved Reviewers', "value": '{{ record.approved_reviewers_names }}' },
            { "label": 'Policy', "value": '{{ record.policy.name }}' },
            { "label": 'Department', "value": '{{ record.department.name }}' },
            { "label": 'Sub Department', "value": '{{ record.sub_department.name }}' },
            { "label": 'Cost Center', "value": '{{ record.cost_center.name }}' },
            { "label": 'PR Number', "value": '{{ record.purchase_request.request_id }}' },
            { "label": 'PR Created by', "value": '{{ record.purchase_request.created_by.name }}' },
            { "label": 'PR Date', "value": "{{ record.purchase_request.created_at | date: '%d-%b-%Y' }}" },
            { "label": 'PO User', "value": '{{ record.user.name }}' },
            { "label": 'PO Status', "value": '{{ record.status.name }}' },
            { "label": 'PO Number', "value": '{{ record.po_number }}' },
            { "label": 'PO Payment Term', "value": '{{ record.payment_term.name }}' },
            { "label": 'PO Creation Date', "value": "{{ record.created_at | date: '%d-%b-%Y' }}" },
            { "label": 'PO Closed Date', "value": "{{ record.closed_at | date: '%d-%b-%Y' }}" },
            { "label": 'PO Delivery Date', "value": "{{ record.delivery_date | date: '%d-%b-%Y' }}" },
            { "label": 'PO Submitted Date', "value": "{{ record.submitted_at | date: '%d-%b-%Y' }}" },
            { "label": 'is PO Approved', "value": '{% if record.is_approved %}Yes{% else %}No{% endif %}' },
            { "label": 'PO Approved On', "value": '' },
            { "label": 'PO Sent On', "value": '' },
            { "label": 'PO Base Value', "value": '{{ record.total_before_tax.value }}' },
            { "label": 'PO CGST', "value": '{{ record.cgst_amount }}' },
            { "label": 'PO SGST', "value": '{{ record.sgst_amount }}' },
            { "label": 'PO IGST', "value": '{{ record.igst_amount }}' },
            { "label": 'PO Line Items Count', "value": '' },
            { "label": 'PO Purchase Address', "value": '{{ record.billing_address }}' },
            { "label": 'PO Delivery Address', "value": '{{ record.shipping_address }}' },
            { "label": 'PO Custom Fields', "value": '' },
            { "label": 'Inward Status', "value": '' },
            { "label": 'Last Inward Received On', "value": '' },
            { "label": 'Invoice Number', "value": '{{ record.invoice.invoice_number }}' },
            { "label": 'Invoice ID', "value": '{{ record.invoice.invoice_id }}' },
            { "label": 'Invoice Payment Term', "value": '' },
            { "label": 'Invoice Delivery Date', "value": '' },
            { "label": 'Invoice Submitted On', "value": '' },
            { "label": 'Invoice Approved On', "value": '' },
            { "label": 'Is Invoice Approved', "value": '{% if record.invoice.is_approved %}Yes{% else %}No{% endif %}' },
            { "label": 'PO Advance Status', "value": '{{ record.advance_amount_status.name }}' },
            { "label": 'Advance Amount', "value": '{{ record.advance_amount.value }}' },
            { "label": 'Advance TDS Amount', "value": '{{ record.advance_tds_amount.value }}' },
            { "label": 'Advance TDS Slab', "value": '{{ record.advance_tds_slab.name }}' },
            { "label": 'Invoice Sent On', "value": '' },
            { "label": 'Invoice CGST', "value": '{{ record.invoice.cgst_amount }}' },
            { "label": 'Invoice SGST', "value": '{{ record.invoice.sgst_amount }}' },
            { "label": 'Invoice IGST', "value": '{{ record.invoice.igst_amount }}' },
            { "label": 'Invoice TDS Type', "value": '{{ record.invoice.tds_slab.name }}' },
            { "label": 'Invoice TDS Rate', "value": '{{ record.invoice.tds_rate.value }}' },
            { "label": 'Invoice TDS Amount', "value": '{{ record.invoice.tds_amount.value }}' },
            { "label": 'Invoice Base Amount', "value": '{{ record.invoice.item_amounts_total }}' },
            { "label": 'Invoice Discount Amount', "value": '{{ record.invoice.discount_amount_value }}' },
            { "label": 'Invoice Total Amount', "value": '{{ record.invoice.net_amount.value }}' },
            { "label": 'Invoice Total Amount after TDS', "value": '{{ record.invoice.net_amount.value | minus: record.invoice.tds_amount.value }}' },
            { "label": 'Invoice Payable Amount', "value": '' },
            { "label": 'Invoice Line Items Count', "value": '' },
            { "label": 'Invoice Purchase Address', "value": '' },
            { "label": 'Invoice Delivery Address', "value": '' },
            { "label": 'Invoice Custom Fields', "value": '' },
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'Spreadsheet (Line Items)',
      "description": 'Purchase Orders Export (Line Items)',
      "export_format": 'csv',
      "resource": 'purchase_order_items',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Description', "value": '{{ record.description }}' },
            { "label": 'Comment', "value": '{{ record.comment }}' },
            { "label": 'Category', "value": '{{ record.inventory_line_item.category.name }}' },
            { "label": 'GL Code', "value": '{{ record.category.gl_code }}' },
            { "label": 'HSN SAC', "value": '{{ record.hsn_sac }}' },
            { "label": 'Quantity', "value": '{{ record.quantity }}' },
            { "label": 'Rate', "value": '{{ record.rate }}' },
            { "label": 'Discount', "value": '{{ record.discount }}' },
            { "label": 'Discount Amount', "value": '{{ record.discount_amount.value }}' },
            { "label": 'Tax', "value": '{{ record.tax_rate.rate }}' },
            { "label": 'Tax Amount', "value": '{{ record.tax_amount.value }}' },
            { "label": 'Total Amount', "value": '{{ record.total_amount.value }}' },
            { "label": 'Procurement Name', "value": '{{ record.purchase_order.name }}' },
            { "label": 'PO Number', "value": '{{ record.purchase_order.po_number }}' },
            { "label": 'PO Creation Date', "value": "{{ record.purchase_order.created_at | date: '%d-%b-%Y' }}" },
            { "label": 'PO Closed Date', "value": "{{ record.purchase_order.closed_at | date: '%d-%b-%Y' }}" },
            { "label": 'Created by', "value": '{{ record.purchase_order.user.name }}' },
            { "label": 'Policy', "value": '{{ record.purchase_order.policy.name }}' },
            { "label": 'Vendor Name', "value": '{{ record.purchase_order.vendor.display_name }}' },
            { "label": 'Vendor Business Name', "value": '{{ record.purchase_order.vendor.business_name }}' },
            { "label": 'Vendor Mobile Number', "value": '{{ record.purchase_order.vendor.mobile_number }}' },
            { "label": 'Vendor State Code', "value": '{{ record.purchase_order.vendor.state_code.code }}' },
            { "label": 'Vendor GSTIN', "value": '{{ record.purchase_order.gstin_location.gstin }}' },
            { "label": 'Vendor PAN', "value": '{{ record.purchase_order.vendor.pan }}' },
            { "label": 'Vendor TDS Rate', "value": '' },
            { "label": 'Vendor TDS Description', "value": '' },
            { "label": 'Vendor Type', "value": '{{ record.purchase_order.vendor.vendor_type.name }}' },
            { "label": 'Vendor Description', "value": '{{ record.purchase_order.vendor.description }}' },
            { "label": 'Vendor Address', "value": '{{ record.purchase_order.vendor.address }}' },
            { "label": 'Approval Pending Level Number', "value": '{{ record.purchase_order.controlling_level.level_number }}' },
            { "label": 'Approval Pending Level Name', "value": '{{ record.purchase_order.controlling_level.name }}' },
            { "label": 'Approval Pending Reviewers', "value": '{{ record.purchase_order.get_reviewers_names }}' },
            { "label": 'Approved Reviewers', "value": '{{ record.purchase_order.approved_reviewers_names }}' },
            { "label": 'Department', "value": '{{ record.purchase_order.department.name }}' },
            { "label": 'Sub Department', "value": '{{ record.purchase_order.sub_department.name }}' },
            { "label": 'Cost Center', "value": '{{ record.purchase_order.cost_center.name }}' },
            { "label": 'PO Status', "value": '{{ record.purchase_order.status.name }}' },
            { "label": 'PO Payment Term', "value": '{{ record.purchase_order.payment_term.name }}' },
            { "label": 'PO Delivery Date', "value": "{{ record.purchase_order.delivery_date | date: '%d-%b-%Y' }}" },
            { "label": 'is PO Approved', "value": '{% if record.purchase_order.is_approved %}Yes{% else %}No{% endif %}' },
            { "label": 'PO Approved On', "value": "{{ record.purchase_order.approved_at | date: '%d-%b-%Y' }}" },
            { "label": 'PO Base Value', "value": '{{ record.purchase_order.total_before_tax.value }}' },
            { "label": 'PO CGST', "value": '{{ record.purchase_order.cgst_amount }}' },
            { "label": 'PO SGST', "value": '{{ record.purchase_order.sgst_amount }}' },
            { "label": 'PO IGST', "value": '{{ record.purchase_order.igst_amount }}' },
            { "label": 'PO Purchase Address', "value": '{{ record.purchase_order.billing_address }}' },
            { "label": 'PO Delivery Address', "value": '{{ record.purchase_order.shipping_address }}' }
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'Users Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'users',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Employee ID', "value": '{{ record.profile.employee_id }}' },
            { "label": 'Name', "value": '{{ record.name }}' },
            { "label": 'Email', "value": '{{ record.email }}' },
            { "label": 'Mobile Number', "value": '{{ record.mobile_number }}' },
            { "label": 'Status', "value": '{{ record.active }}' }
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'Item Master Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'items',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Item Number', "value": '{{ record.item_number }}' },
            { "label": 'GL Code', "value": '{{ record.item_code }}' },
            { "label": 'Description', "value": '{{ record.description }}' },
            { "label": 'Product Type', "value": '{{ record.product_type }}' },
            { "label": 'Active', "value": '{{ record.active }}' },
            { "label": 'Category', "value": '{{ record.category.name }}' },
            { "label": 'HSN SAC', "value": '{{ record.hsn_sac }}' },
            { "label": 'SKU', "value": '{{ record.sku }}' },
            { "label": 'Expense Type', "value": '{{ record.expense_type }}' },
            { "label": 'TDS Applicable', "value": '{{ record.tds_applicable }}' },
            { "label": 'Tax Rate', "value": '{{ record.tax_rate.name }} - {{ record.tax_rate.rate }}' },
            { "label": 'Item Rate', "value": '{{ record.rate }}' },
            { "label": 'Supply Item Type', "value": '{{ record.scope }}' },
            { "label": 'Unit of Measurement', "value": '{{ record.unit_of_measurement }}' },
            { "label": 'Created User', "value": '{{ record.created_by.first_name }} {{ record.created_by.last_name }}' },
            { "label": 'Created at', "value": "{{ record.created_at | date: '%d-%b-%Y' }}" }
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'Vendor Export',
      "description": '',
      "export_format": 'csv',
      "resource": 'vendors',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'Vendor Business Name', "value": '{{ record.business_name }}' },
            { "label": 'Vendor Trade Name', "value": '{{ record.trade_name }}' },
            { "label": 'Vendor ID', "value": '{{ record.vendor_id }}' },
            { "label": 'Name', "value": '{{ record.name }}' },
            { "label": 'MSME Registered', "value": '{{ record.msme_registered }}' },
            { "label": 'MSME Registration Number', "value": '{{ record.msme_registration_number }}' },
            { "label": 'Mobile Number', "value": '{{ record.mobile_number }}' },
            { "label": 'Email', "value": '{{ record.email }}' },
            { "label": 'Created By', "value": '{{ record.created_by.name }}' },
            { "label": 'PAN', "value": '{{ record.pan }}' },
            { "label": 'POC Name', "value": '{{ record.gstin_location.poc_name }}' },
            { "label": 'POC Email', "value": '{{ record.gstin_location.poc_email }}' },
            { "label": 'GSTIN Location Address', "value": '{{ record.gstin_location.address }}' },
            { "label": 'GSTIN', "value": '{{ record.gstin_location.gstin }}' },
            { "label": 'TDS Percentage', "value": '' },
            { "label": 'State Code', "value": '{{ record.state_code.name }} - {{ record.state_code.code }}' },
            { "label": 'Description', "value": '{{ record.description }}' },
            { "label": 'Vendor Type', "value": '{{ record.vendor_type.name }}' },
            { "label": 'Default Account Number', "value": '{{ record.bank_accounts[0].account_number }}' },
            { "label": 'Default Account Name', "value": '{{ record.bank_accounts[0].name }}' },
            { "label": 'Default Account IFSC', "value": '{{ record.bank_accounts[0].ifsc }}' },
            { "label": 'Second Account Number', "value": '{{ record.bank_accounts[1].account_number }}' },
            { "label": 'Second Account Name', "value": '{{ record.bank_accounts[1].name }}' },
            { "label": 'Second Account IFSC', "value": '{{ record.bank_accounts[1].ifsc }}' },
            { "label": 'Third Account Number', "value": '{{ record.bank_accounts[2].account_number }}' },
            { "label": 'Third Account Name', "value": '{{ record.bank_accounts[2].name }}' },
            { "label": 'Third Account IFSC', "value": '{{ record.bank_accounts[2].ifsc }}' },
            { "label": 'Fourth Account Number', "value": '{{ record.bank_accounts[3].account_number }}' },
            { "label": 'Fourth Account Name', "value": '{{ record.bank_accounts[3].name }}' },
            { "label": 'Fourth Account IFSC', "value": '{{ record.bank_accounts[3].ifsc }}' },
            { "label": 'Created at', "value": "{{ record.created_at | date: '%d-%b-%Y' }}" },
            { "label": 'Active', "value": '{% if record.deactivated %}FALSE{% else %}TRUE{% endif %}' },
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    {
      "name": 'Spreadsheet',
      "description": 'Utility Bills',
      "export_format": 'csv',
      "resource": 'utility_bills',
      "default": true,
      "template": JSON.generate(
        {
          "columns": [
            { "label": 'ID', "value": '{{ record.id }}' },
            { "label": 'Bill Sequence ID', "value": '{{ record.bill_id }}' },
            { "label": 'Subscription ID', "value": '{{ record.subscription.id }}' },
            { "label": 'Subscription Sequence ID', "value": '{{ record.subscription.subscription_id }}' },
            { "label": 'Subscription Name', "value": '{{ record.subscription.name }}' },
            { "label": 'BBPS Biller ID', "value": '{{ record.subscription.biller.biller_id }}' },
            { "label": 'Point of Contacts', "value": '{% for user in record.subscription.pocs %}{{user.name}} {{user.email}}, {% endfor %}' },
            { "label": 'Assignee', "value": '{{ record.user.name }} {{ record.user.email }}' },
            { "label": 'Department', "value": '{{ record.department.name }}' },
            { "label": 'Cost Center', "value": '{{ record.cost_center.name }}' },
            { "label": 'Location', "value": '{{ record.location.name }}' },
            { "label": 'Policy', "value": '{{ record.policy.name }}' },
            { "label": 'Current Approval Level', "value": '{% if record.awaiting_approval %}{{ record.level.level_number }} - {{ record.level.name }}{% else %}NA{%endif%}' },
            { "label": 'Awaiting Approval From', "value": '{% if record.awaiting_approval %}{% for user in record.get_reviewers %}{{ record.user.name }} - {{ record.user.email }}, {% endfor %}{% else %}NA{% endif %}' },
            { "label": 'Mobile Number', "value": '{{ record.subscription.mobile_number }}' },
            { "label": 'Customer Param Key 1', "value": '{{ record.subscription.customer_param_key_1 }}' },
            { "label": 'Customer Param Value 1', "value": '{{ record.subscription.customer_param_value_1 }}' },
            { "label": 'Customer Param Key 2', "value": '{{ record.subscription.customer_param_key_2 }}' },
            { "label": 'Customer Param Value 2', "value": '{{ record.subscription.customer_param_value_2 }}' },
            { "label": 'Customer Param Key 3', "value": '{{ record.subscription.customer_param_key_3 }}' },
            { "label": 'Customer Param Value 3', "value": '{{ record.subscription.customer_param_value_3 }}' },
            { "label": 'Customer Param Key 4', "value": '{{ record.subscription.customer_param_key_4 }}' },
            { "label": 'Customer Param Value 4', "value": '{{ record.subscription.customer_param_value_4 }}' },
            { "label": 'Customer Param Key 5', "value": '{{ record.subscription.customer_param_key_5 }}' },
            { "label": 'Customer Param Value 5', "value": '{{ record.subscription.customer_param_value_5 }}' },
            { "label": 'Bill Generation Type', "value": '{% if record.auto_fetched %}Auto Fetched{% else %}Manually Created{% endif %}' },
            { "label": 'Bill Validation Supported', "value": '{% if record.subscription.support_bill_validation == "MANDATORY" %}Mandatory{% else %}Optional / Not Required{% endif %}' },
            { "label": 'Status', "value": '{{ record.status.name }}' },
            { "label": 'Amount', "value": '{{ record.amount.value }}' },
            { "label": 'Early Payment Fee Selected', "value": '{{ record.early_payment_fee_selected }}' },
            { "label": 'Late Payment Fee Selected', "value": '{{ record.late_payment_fee_selected }}' },
            { "label": 'Convenience Fee Selected', "value": '{{ record.convenience_fee_selected }}' },
            { "label": 'Total Amount ID', "value": '{{ record.total_amount.value }}' },
            { "label": 'Expected Due Date', "value": '{{ record.expected_due_date | date: "%d-%d-%Y" }}' },
            { "label": 'Created At', "value": '{{ record.created_at | date: "%I:%M %p, %d %b %Y" }}' },
            { "label": 'Last Updated At', "value": '{{ record.updated_at | date: "%I:%M %p, %d %b %Y" }}' },
            { "label": 'Submitted At', "value": '{{ record.submitted_at | date: "%I:%M %p, %d %b %Y" }}' },
            { "label": 'Approved At', "value": '{{ record.approved_at | date: "%I:%M %p, %d %b %Y" }}' },
            { "label": 'Note', "value": '{{ record.note }}' },
            { "label": 'Due Date', "value": "{{ record.due_date | date: '%d-%b-%Y' }}" },
            { "label": 'Bill Date', "value": '{{ record.bill_date | date: "%d-%b-%Y" }}' },
            { "label": 'Bill Number', "value": '{{ record.bill_number }}' },
            { "label": 'Paid On Date', "value": '{% if record.is_paid %}{{ record.paid_on_date | date: "%d-%b-%Y" }}{%endif%}' },
            { "label": 'Transaction ID', "value": '{{ record.transaction_id }}' },
            { "label": 'BBPS ID', "value": '{{ record.bbps_id }}' },
            { "label": 'Bill Period', "value": '{{ record.bill_period }}' },
            { "label": 'Customer Name', "value": '{{ record.subscription.customer_name }}' },
            { "label": 'Customer Email', "value": '{{ record.subscription.customer_email }}' },
            { "label": 'Customer Aadhar Number', "value": '{{ record.subscription.customer_aadhar_number }}' },
            { "label": 'Customer PAN', "value": '{{ record.subscription.customer_pan }}' },
            { "label": 'Tax Rate', "value": '{{record.tax_rate.name}} - {{record.tax_rate.rate}}' },
            { "label": 'Category', "value": '{{ record.category.name }}' },
            { "label": 'HSN SAC', "value": '{{ record.hsn_sac }}' },
            { "label": 'Paid at', "value": '{% if record.is_paid %}{{ record.paid_at | date: "%I:%M %p, %d %b %Y" }}{% else %}NA{%endif%}' },
          ]
        }
      ),
      "query": JSON.generate({}),
      "personal": false
    },
    # {
    #   "name": 'Tally Export',
    #   "description": '',
    #   "export_format": 'xml',
    #   "resource": 'invoices',
    #   "template": File.open("tally_export_template.xml").read,
    #   "query": JSON.generate({}),
    #   "personal": false
    # }
  ].freeze

  def self.seed_data
    Company.find_each do |company|
      DEFAULT_TEMPLATES.each do |template|
        ExportTemplateNew.create! template.merge(company_id: company.id, created_by_id: 1)
      end
    end
  end
end
