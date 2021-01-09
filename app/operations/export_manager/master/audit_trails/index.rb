class ExportManager::Master::AuditTrails::Index < ExportManager::Builders::Spreadsheet

  label 'Export'
  description 'Audit Trail Export'
  configurable true
  system :vp
  screen 'audit_trails.index'
  handle :audit_trails
  validate :input

  attribute :description
  attribute :document_type
  attribute :document_number
  attribute :date_time
  attribute :changes
  attribute :user_name
  attribute :user_email
  attribute :action
  attribute :user_ip
  #attribute :user_agent

  def data
    @data = input
    update total_records: @data.count.count
    @data
  end

  def input
    audit_trails = Resolver::Router.dispatch('audit_trails.default', params: params.merge(filter: true, paginate: false), current_user: user)
      #AuditTrail.where(company_id: user.company_id).where("versions.user_transaction_id IN (#{audit_trails.select('user_transaction_id').to_sql})").order(created_at: :desc)
  end

  def description(item)
    item.to_exposure.description
  end

  def date_time(item)
    item.created_at
  end

  def changes(item)
    item.to_exposure.changes_less
  end

  def document_type(item)
    item.to_exposure.parent_document_type
  end

  def document_number(item)
    item.to_exposure.document_number
  end

  def user_name(item)
    item.to_exposure.created_by&.name
  end

  def user_email(item)
    item.to_exposure.created_by&.email
  end

  def action(item)
    item.to_exposure.event.capitalize
  end

  def user_ip(item)
    item.user_ip
  end

end