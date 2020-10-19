class ExportManager::Master::Invoices::GstExport < ExportManager::Builders::Template

  label 'Gst Export'
  description 'Gst Export'
  export_format 'csv'
  resource 'invoice_line_items'
  subscribe 'invoice_line_items'

  roles [:admin, :finance_manager]

  attribute :invoice_number, template: '{{ record.invoice.invoice_number }}'
  attribute :finly_ref_no, template: '{{ record.invoice.invoice_id }}'
  attribute :finance_approved_date, template: "{{ record.invoice.approved_at | date: '%d-%b-%Y' }}"
  attribute :vendor_gstin, template: '{{ record.invoice.gstin_location.gstin }}'
  attribute :billing_location, template: '{{ record.invoice.billing_location.name }}'
  attribute :shipping_location, template: '{{ record.invoice.shipping_location.name }}'
  attribute :gl_code, template: '{{ record.category.gl_code }}'
  attribute :description, template: '{{ record.description }}'
  attribute :invoice_net_payable_amount, template: '{{ record.invoice.balance_due_value }}'
  attribute :invoice_base_amount, template: '{{ record.invoice.base_amount }}'
  attribute :total_tax, template: '{{ record.tax_amount.value }}'
  attribute :item_rate, template: '{{ record.rate }}'
  attribute :item_igst_amount, template: '{{ record.igst_amount }}'
  attribute :item_cgst_amount, template: '{{ record.cgst_amount }}'
  attribute :item_sgst_amount, template: '{{ record.sgst_amount }}'
  attribute :item_igst, template: '{{ record.igst }}'
  attribute :item_cgst, template: '{{ record.cgst }}'
  attribute :item_sgst, template: '{{ record.sgst }}'
  attribute :igst_account_number, template: '{{ record.tax_rate.igst_account_number }}'
  attribute :cgst_account_number, template: '{{ record.tax_rate.cgst_account_number }}'
  attribute :sgst_account_number, template: '{{ record.tax_rate.sgst_account_number }}'
  attribute :hsn_sac, template: '{{ record.hsn_sac }}'
  attribute :reverse_charge, template: '0'
  attribute :reverse_charge_tax_gl_account, template: 'N'
  attribute :calculate_tax_for_rct, template: 'N'
  attribute :invoice_status, template: '{{ record.invoice.status.name }}'
  attribute :itc_qualified, template: '{{ record.itc_qualified }}'
  attribute :country, template: '{{ record.country }}'
  attribute :vendor_name, template: '{{ record.invoice.vendor.business_name }}'
  attribute :department_code, template: '{{ record.department.department_code }}'

  # def input
  #   invoices = Resolver::Router.dispatch('invoices.default', {current_user: user, params: params})
  #   InvoiceLineItem.where(parent_type: "Invoice").where("parent_id IN (#{invoices.select('id').to_sql})").includes({purchase_order_item: :purchase_order}, :category, :department, :tax_rate, :cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency}, :discount_amount, parent: [:invoice_attachments, :invoice_type, :vendor, :delivery_location, :invoice_status, :location, :tds_slab, :advance_amount, :balance_due, :discount_amount, :created_by, :gstin_location, {dlrms: [:reviewer, :taken_control_by, :forwarded_to]}, {custom_fields: [:value, :field_configuration]}, {tds_amount: :currency}, :amount, {procurement: [{purchase_order: :advance_amount}]}]).order(parent_id: :asc)
  # end

  # def invoice_number(invoice_line_item)
  #   invoice_line_item.parent.invoice_number
  # end

  # def finly_ref_no(invoice_line_item)
  #   invoice_line_item.parent.invoice_id
  # end

  # def finance_approved_date(invoice_line_item)
  #   invoice_line_item.parent&.approved_at&.strftime("%d-%b-%Y")
  # end

  # def vendor_gstin(invoice_line_item)
  #   invoice_line_item.parent&.gstin_location&.gstin
  # end

  # def billing_location(invoice_line_item)
  #   invoice_line_item.parent&.location&.name
  # end

  # def shipping_location(invoice_line_item)
  #   invoice_line_item.parent&.delivery_location&.name
  # end

  # def gl_code(invoice_line_item)
  #   invoice_line_item&.category&.gl_code
  # end

  # def description(invoice_line_item)
  #   invoice_line_item.description
  # end

  # def invoice_net_payable_amount(invoice_line_item)
  #   invoice_line_item.parent&.balance_due&.value || 0
  # end

  # def invoice_base_amount(invoice_line_item)
  #   invoice_line_item.parent.include_original_amount
  # end

  # def total_tax(invoice_line_item)
  #   invoice_line_item.tax_amount&.value
  # end

  # def item_rate(invoice_line_item)
  #   invoice_line_item.rate
  # end

  # def item_sgst_amount(invoice_line_item)
  #   invoice_line_item.sgst || 0
  # end

  # def item_cgst_amount(invoice_line_item)
  #   invoice_line_item.cgst || 0
  # end

  # def item_igst_amount(invoice_line_item)
  #   invoice_line_item.igst || 0
  # end

  # def item_igst(invoice_line_item)
  #   invoice_line_item&.tax.to_f if invoice_line_item.parent&.gst_type_id == GstType.id_for(:igst)
  # end

  # def item_cgst(invoice_line_item)
  #   (invoice_line_item&.tax.to_f / 2.0) if invoice_line_item.parent&.gst_type_id == GstType.id_for(:cgst_sgst)
  # end

  # def item_sgst(invoice_line_item)
  #   (invoice_line_item&.tax.to_f / 2.0) if invoice_line_item.parent&.gst_type_id == GstType.id_for(:cgst_sgst)
  # end

  # # TODO ADD SGST state remove
  # # TODO ADD SGST ACCOUNT NUMBER internal id DONE

  # def igst_account_number(invoice_line_item)
  #   invoice_line_item.tax_rate&.igst_internal_id
  # end

  # def sgst_account_number(invoice_line_item)
  #   invoice_line_item.tax_rate&.sgst_internal_id
  # end

  # def cgst_account_number(invoice_line_item)
  #   invoice_line_item.tax_rate&.cgst_internal_id
  # end

  # def hsn_sac(invoice_line_item)
  #   invoice_line_item.hsn_sac
  # end

  # # TODO REVERSE CHARGE

  # def reverse_charge(invoice_line_item)
  #   0
  # end

  # def reverse_charge_tax_gl_account(invoice_line_item)
  #   "N"
  # end

  # def calculate_tax_for_rct(invoice_line_item)
  #   "N"
  # end

  # def invoice_status(invoice_line_item)
  #   invoice_line_item.parent&.status&.name&.humanize
  # end

  # # TODO ADD ITEM SERIAL NUMBER
  # # TODO ADD ITC QUALIFIED based on item gst DONE

  # def itc_qualified(invoice_line_item)
  #   invoice_line_item.parent.items.map {|i| i.tax_rate.present?}.compact.present?
  # end

  # def country(invoice_line_item)
  #   invoice_line_item.amount&.currency&.country
  # end

  # def vendor_name(invoice_line_item)
  #   invoice_line_item.parent.vendor&.display_name
  # end

  # def department_code(invoice_line_item)
  #   invoice_line_item.department&.department_code
  # end

  # def cost_center_code(invoice_line_item)
  #   invoice_line_item.cost_center&.cost_center_code
  # end

end
