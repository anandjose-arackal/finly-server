class ExportManager::Master::Invoices::InvoiceLineItems::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Audit Trail Export'
  configurable true

  system :vp
  handle :audit_trails
  validate :input

  attribute :user_transaction_id
  attribute :item_id
  attribute :item_type
  attribute :event


  def input
    audit_trails = Resolver::Router.dispatch('audit_trails.default', params: params.merge(filter: true, paginate: false), current_user: user)
    AuditTrail.where(company_id: user.company_id).where("versions.user_transaction_id IN (#{audit_trails.select('user_transaction_id').to_sql})").order(created_at: :desc)
  end

  def user_transaction_id(item)
    item.user_transaction_id
  end

  def item_id(item)
    item.item_id
  end

  def item_type(item)
    item.item_type
  end

  def event(item)
    item.event
  end

end