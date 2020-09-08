class ExportManager::Master::Invoices::Index < ExportManager::Builders::Template

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

  # TODO: We could figure out a way to add custom_fields too

  # section :custom_fields do
  #   attribute :custom_fields, dynamic: true
  # end

  # def custom_fields(row, invoice_line_item)
  #   invoice_line_item.parent.custom_fields.includes(:field_configuration).each do |custom_field|
  #     row.add(custom_field.field_configuration.field_name, custom_field.string_value)
  #   end
  # end
  
  # def input
  #   invoices = resolve 'invoices.default'
  #   InvoiceLineItem.where(parent_type: "Invoice").where("parent_id IN (#{invoices.select('id').to_sql})").includes({purchase_order_item: :purchase_order}, :category, :department, :tax_rate, :cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency}, :discount_amount, parent: [:invoice_attachments, :invoice_type, :vendor, :delivery_location, :invoice_status, :location, :tds_slab, :advance_amount, :balance_due, :discount_amount, :created_by, :gstin_location, {dlrms: [:reviewer, :taken_control_by, :forwarded_to]}, {custom_fields: [:value, :field_configuration]}, {tds_amount: :currency}, :amount, {procurement: [{purchase_order: :advance_amount}]}]).order(parent_id: :asc)
  # end

  # def po_number(invoice_line_item)
  #   invoice_line_item.parent&.procurement&.purchase_order&.po_number
  # end

  # def invoice_date(invoice_line_item)
  #   invoice_line_item.parent&.date&.strftime("%d-%b-%y")
  # end

  # def billing_location(invoice_line_item)
  #   invoice_line_item.parent&.location&.name
  # end

  # def shipping_location(invoice_line_item)
  #   invoice_line_item.parent&.delivery_location&.name
  # end

  # def vendor_ref_num(invoice_line_item)
  #   invoice_line_item.parent&.vendor_id
  # end

  # def total_tax(invoice_line_item)
  #   invoice_line_item.tax_amount&.value
  # end

  # def finly_ref_no(invoice_line_item)
  #   invoice_line_item.parent&.invoice_id
  # end

  # def invoice_type(invoice_line_item)
  #   # [:tax_invoice, :advance, :non_po_invoice, :beneficiary, :proforma_invoice]
  #   case invoice_line_item.parent.invoice_type&.name
  #   when 'tax_invoice'
  #     "PO Invoice"
  #   when 'non_po_invoice'
  #     "NON PO Invoice"
  #   when 'proforma_invoice'
  #     "Proforma Invoice"
  #   else
  #     "Invoice"
  #   end
  # end

  # def invoice_no(invoice_line_item)
  #   invoice_line_item.parent&.invoice_number
  # end

  # def vendor_name(invoice_line_item)
  #   invoice_line_item.parent.vendor&.display_name
  # end

  # def vendor_ref_no(invoice_line_item)
  #   invoice_line_item.parent.vendor&.vendor_id
  # end

  # def vendor_gstin(invoice_line_item)
  #   invoice_line_item.parent&.gstin_location&.gstin
  # end

  # def vendor_state(invoice_line_item)
  #   invoice_line_item.parent&.gstin_location&.state&.name
  # end

  # # def vendor_gst(invoice_line_item)
  # #   invoice_line_item
  # # end

  # # def po_number(invoice_line_item)
  # #   invoice_line_item
  # # end

  # def transaction_period_from(invoice_line_item)
  #   invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%b-%y")
  # end

  # def transaction_period_to(invoice_line_item)
  #   invoice_line_item.parent.transaction_service_period_to&.strftime("%d-%b-%y")
  # end

  # def invoice_status(invoice_line_item)
  #   invoice_line_item.parent&.status&.name&.humanize
  # end

  # def is_invoice_approved(invoice_line_item)
  #   InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid, :approved, :auto_approved, :closed, :pending, :initiated).include?(invoice_line_item.parent&.invoice_status_id) ? 'Yes' : 'No'
  # end

  # def category(invoice_line_item)
  #   invoice_line_item&.category&.name
  # end

  # def quantity(invoice_line_item)
  #   invoice_line_item&.quantity
  # end

  # def rate(invoice_line_item)
  #   invoice_line_item&.rate
  # end

  # def narration(invoice_line_item)
  #   invoice_line_item.parent&.narration
  # end

  # def location_name(invoice_line_item)
  #   invoice_line_item.parent.location&.name
  # end

  # def location_code(invoice_line_item)
  #   invoice_line_item.parent.location&.location_code
  # end

  # def department_name(invoice_line_item)
  #   invoice_line_item.department&.name
  # end

  # def department_code(invoice_line_item)
  #   invoice_line_item.department&.department_code
  # end

  # def gst_group(invoice_line_item)
  #   invoice_line_item&.tax_rate&.name
  # end

  # def hsn_sac(invoice_line_item)
  #   invoice_line_item.hsn_sac
  # end

  # # def tds_nature(invoice_line_item)
  # #   invoice_line_item
  # # end

  # def cost_center(invoice_line_item)
  #   invoice_line_item.cost_center&.name
  # end

  # def item_code(invoice_line_item)
  #   invoice_line_item.inventory_line_item&.item_code
  # end

  # def description(invoice_line_item)
  #   invoice_line_item&.description
  # end

  # def unit_of_measurement(invoice_line_item)
  #   invoice_line_item&.unit_of_measurement
  # end

  # def total_amount(invoice_line_item)
  #   if invoice_line_item&.parent&.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
  #     # return (invoice_line_item.amount&.value.to_f - invoice_line_item.tds_amount)&.abs
  #     return invoice_line_item.amount&.value.to_f
  #   end
  #   # (invoice_line_item.inventory_line_item&.product_type_id == ProductType.id_for(:service)) ? (invoice_line_item.billable_amount&.value.to_f - invoice_line_item.tds_amount)&.abs : (invoice_line_item.amount&.value.to_f - invoice_line_item.tds_amount)&.abs
  #   (invoice_line_item.inventory_line_item&.product_type_id == ProductType.id_for(:service)) ? invoice_line_item.billable_amount&.value.to_f : invoice_line_item.amount&.value.to_f
  # end

  # def tax_amount(invoice_line_item)
  #   invoice_line_item.tax_amount&.value
  # end

  # def tax_rate(invoice_line_item)
  #   invoice_line_item.tax_rate&.rate
  # end

  # def tax_type(invoice_line_item)
  #   invoice_line_item.tax_rate&.name
  # end

  # def tds_nature(invoice_line_item)
  #   return false unless invoice_line_item&.tds_applicable
  #   invoice_line_item.parent.tds_slab&.name
  # end

  # def tds_amount(invoice_line_item)
  #   return 0.0 unless invoice_line_item&.tds_applicable
  #   invoice_line_item.tds_amount # show line item wise tds instead of header
  #   # invoice_line_item.parent.tds_amount&.value || 0.0
  # end

  # def rcm_enabled(invoice_line_item)
  #   return invoice_line_item.parent&.rcm_enabled
  # end

  # def tds_percentage(invoice_line_item)
  #   return 0.0 unless invoice_line_item&.tds_applicable
  #   invoice_line_item.parent.tds_slab&.tds || 0.0
  # end

  # def invoice_discount(invoice_line_item)
  #   invoice_line_item.parent&.discount_amount&.value || 0
  # end

  # def line_item_discount(invoice_line_item)
  #   invoice_line_item.discount_amount&.value || 0
  # end

  # def line_item_sgst(invoice_line_item)
  #   return 0 if invoice_line_item.tax_rate_id.nil?
  #   invoice_line_item.sgst || 0
  # end

  # def line_item_cgst(invoice_line_item)
  #   return 0 if invoice_line_item.tax_rate_id.nil?

  #   invoice_line_item.cgst || 0
  # end

  # def line_item_igst(invoice_line_item)
  #   return 0 if invoice_line_item.tax_rate_id.nil?
  #   invoice_line_item.igst || 0
  # end

  # def advance_amount(invoice_line_item)
  #   if invoice_line_item.parent&.invoice_type_id == InwardInvoiceType.id_for(:non_po_invoice)
  #     value = invoice_line_item.parent&.advance_amount&.value || 0
  #   else
  #     value = invoice_line_item.parent&.procurement&.purchase_order&.advance_amount&.value || 0
  #   end
  #   precision_value(value)
  # end

  # def approvers(invoice_line_item)
  #   approvers = invoice_line_item.parent.dlrms.map do |dlrm|
  #     taken_control_by = forwarded_to = reviewer = nil
  #     taken_control_by = dlrm.taken_control_by
  #     forwarded_to = dlrm.forwarded_to
  #     reviewer = dlrm.reviewer
  #     approved = [TrailAction.id_for(:approve), TrailAction.id_for(:approve_and_forward)].include?(dlrm.action_id)
  #     action_taken = (dlrm.action_taken_at.present? ? dlrm.action_taken_at.strftime("%I:%M %p, %d %b %Y") : dlrm.updated_at.strftime("%I:%M %p, %d %b %Y"))
  #     if forwarded_to.present?
  #       (approved ? "#{forwarded_to.name} - #{action_taken}" : forwarded_to.name)
  #     elsif taken_control_by.present?
  #       (approved ? "#{taken_control_by.name} - #{action_taken}" : taken_control_by.name)
  #     elsif reviewer.present?
  #       (approved ? "#{reviewer.name} - #{action_taken}" : reviewer.name)
  #     end
  #   end
  #   approvers.reject { |e| e.to_s.empty? }.join(", ")
  # end

  # def invoice_net_payable_amount(invoice_line_item)
  #   invoice_line_item.parent&.balance_due&.value || 0
  # end

  # def finance_approved_date(invoice_line_item)
  #   invoice_line_item.parent&.approved_at&.strftime("%d-%b-%Y")
  # end

  # def created_by(invoice_line_item)
  #   invoice_line_item.parent&.created_by&.name
  # end

  # def created_at(invoice_line_item)
  #   invoice_line_item.parent&.created_at&.strftime("%d-%b-%Y")
  # end

  # def po_date(invoice_line_item)
  #   invoice_line_item.purchase_order_item&.purchase_order&.created_at&.strftime("%d-%b-%Y")
  # end

  # def policy(invoice_line_item)
  #   invoice_line_item.parent&.policy&.name
  # end

  # def due_date(invoice_line_item)
  #   invoice_line_item.parent&.due_date&.strftime("%d-%b-%Y")
  # end

  # def attachments(invoice_line_item)
  #   invoice_line_item.parent.attachments.map {|a| a.file.url(:original, timestamp: false)}.compact.join(", ")
  # end

  # def approval_pending_reviewers(invoice_line_item)
  #   invoice_line_item.parent.get_reviewers&.map(&:name)&.join(", ")
  # end

  # def invoice_amount(invoice_line_item)
  #   parent_invoice  = invoice_line_item.parent
  #   ((parent_invoice&.balance_due&.value || 0 ) + (parent_invoice&.po_adjusted_advance&.value || 0) || 0)
  # end

end
