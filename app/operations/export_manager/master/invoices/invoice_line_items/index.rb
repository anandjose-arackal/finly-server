class ExportManager::Master::Invoices::InvoiceLineItems::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Invoices Export'
  configurable true
  # screen 'invoices.index'
  system :vp
  handle :non_po_items
  validate :input

  attribute :procurement_name
  attribute :invoice_id
  attribute :invoice_number
  attribute :invoice_date
  attribute :created_by
  attribute :description
  attribute :comment
  attribute :category
  attribute :policy
  attribute :hsn_sac
  attribute :quantity
  attribute :rate
  attribute :discount
  attribute :discount_amount
  attribute :tax
  attribute :tax_amount
  attribute :total_amount

  def input
    invoices = Resolver::Router.dispatch('invoices.default', params: params.merge(filter: true, paginate: false), current_user: user)
    InvoiceLineItem.where(parent_type: "Invoice").where("parent_id IN (#{invoices.select('id').to_sql})").order(parent_id: :asc)
  end

  def procurement_name(item)
    procurement(item)&.name
  end

  def invoice_id(item)
    invoice(item)&.invoice_id
  end

  def invoice_number(item)
    "\t" + (invoice(item)&.invoice_number).to_s
  end

  def invoice_date(item)
    invoice(item)&.date&.strftime("%d-%b-%Y")
  end

  def created_by(item)
    invoice(item)&.created_by&.name
  end

  def description(item)
    item.description
  end

  def comment(item)
    item.comment
  end

  def category(item)
    inventory_line_item(item)&.category&.name
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
    value = item.net_amount&.value || 0
    precision_value(value)
  end

  def policy(item)
    item&.parent&.policy&.name
  end

  protected

  def invoice(item)
    item&.parent
  end

  def procurement(item)
    invoice(item)&.procurement
  end

  def inventory_line_item(item)
    item.inventory_line_item
  end
end