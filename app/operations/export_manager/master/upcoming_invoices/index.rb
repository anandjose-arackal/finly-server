class ExportManager::Master::UpcomingInvoices::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'UpcomingInvoices Export'
  configurable true
  handle :upcoming_invoices
  screen 'upcoming_invoices.index'
  system :vp

  attribute :vendor_business_name
  attribute :vendor_id
  attribute :created_by
  attribute :invoice_type
  attribute :start_date
  attribute :end_date
  attribute :due_date
  attribute :due_in_days
  attribute :agreement_number
  attribute :agreement_date
  attribute :agreement_execution_date
  attribute :agreement_expiry_date
  attribute :gross_amount
  attribute :discount_amount
  attribute :cgst_amount
  attribute :sgst_amount
  attribute :igst
  attribute :tds_slab
  attribute :tds_rate
  attribute :tds_amount
  attribute :freight_amount
  attribute :net_amount
  attribute :advance_amount
  attribute :balance_due
  attribute :cost_center
  attribute :department
  attribute :vendor_location
  attribute :billing_location
  attribute :shipping_location
  attribute :policy
  attribute :created_at

  section :custom_fields do
    # attribute :custom_fields, dynamic: true
  end

  def input
    invoices = resolve 'upcoming_invoices.default'
  end

  def vendor_business_name invoice
    invoice&.vendor&.business_name
  end

  def vendor_id invoice
    invoice&.vendor&.vendor_id
  end

  def created_by invoice
    invoice&.created_by&.name
  end

  def invoice_type invoice
    invoice&.class&.name&.titleize
  end

  def start_date invoice
    invoice&.start_date&.strftime("%d-%m-%Y")
  end

  def end_date invoice
    invoice&.end_date&.strftime("%d-%m-%Y")
  end

  def due_date invoice
    invoice&.due_date&.strftime("%d-%m-%Y")
  end

  def due_in_days invoice
    invoice&.due_in_days
  end

  def agreement_number invoice
    invoice&.payment_agreement&.order_number
  end

  def agreement_date invoice
    invoice&.payment_agreement&.agreement_date&.strftime("%d-%m-%Y")
  end

  def agreement_execution_date invoice
    invoice&.payment_agreement&.execution_date&.strftime("%d-%m-%Y")
  end

  def agreement_expiry_date invoice
    invoice&.payment_agreement&.expiration_date&.strftime("%d-%m-%Y")
  end

  def gross_amount invoice
    invoice&.gross_amount&.value.to_f
  end

  def discount_amount invoice
    invoice&.discount_amount&.value.to_f
  end

  def cgst_amount invoice
    invoice&.tax_amount&.value.to_f
  end

  def sgst_amount invoice
    invoice&.tax_amount&.value.to_f
  end

  def igst invoice
    invoice&.tax_amount&.value.to_f
  end

  def tds_slab invoice
    invoice&.tds_slab&.name
  end

  def tds_rate invoice
    invoice&.tds_slab&.rate.to_f
  end

  def tds_amount invoice
    invoice&.tds_amount&.value.to_f
  end

  def freight_amount invoice
    invoice&.freight_amount&.value.to_f
  end

  def net_amount invoice
    invoice&.net_amount&.value.to_f
  end

  def advance_amount invoice
    invoice&.advance_amount&.value.to_f
  end

  def balance_due invoice
    invoice&.balance_due.value.to_f
  end

  def cost_center invoice
    invoice&.cost_center.name
  end

  def department invoice
    invoice&.department.name
  end

  def vendor_location invoice
    invoice&.vendor_location&.location
  end

  def billing_location invoice
    invoice&.location&.name
  end

  def shipping_location invoice
    invoice&.delivery_location&.name
  end

  def policy invoice
    invoice&.payment_agreement&.policy&.name
  end

  def created_at invoice
    invoice&.created_at&.strftime("%d-%m-%Y")
  end
end