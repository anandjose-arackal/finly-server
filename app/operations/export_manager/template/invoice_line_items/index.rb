# TODO: find better way to get results
class ExportManager::Template::InvoiceLineItems::Index

  def self.input(user, params)
    invoices = Resolver::Router.dispatch('invoices.default', {current_user: user, params: params})
    InvoiceLineItem.where(parent_type: "Invoice").where("parent_id IN (#{invoices.select('id').to_sql})").includes({purchase_order_item: :purchase_order}, :category, :department, :tax_rate, :cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency}, :discount_amount, parent: [:invoice_attachments, :invoice_type, :vendor, :delivery_location, :invoice_status, :location, :tds_slab, :advance_amount, :balance_due, :discount_amount, :created_by, :gstin_location, {dlrms: [:reviewer, :taken_control_by, :forwarded_to]}, {custom_fields: [:value, :field_configuration]}, {tds_amount: :currency}, :amount, {procurement: [{purchase_order: :advance_amount}]}]).order(parent_id: :asc)
  end

end