class ExportManager::Template::Master::AuditTrails::Index < ExportManager::Builders::Template

  label 'Export'
  description 'Audit Trails Export'
  export_format 'xls'
  resource 'audit_trails'
  subscribe 'audit_trails'
  default true

  attribute :description, template: '{{ record.description }}'
  attribute :document_type, template:  '{{ record.parent_document_type, }}'
  attribute :document_number, template:  '{{ record.document_number }}'
  attribute :date_time, template:  '{{ record.created_at }}'
  attribute :document_change_affected, template:  '{{ record.document_change_affected }}'
  attribute :changes, template:  '{{ record.changes }}'
  attribute :user_name, template:  '{{ record.user.name }}'
  attribute :user_email, template:  '{{ record.user.email }}'
  attribute :action, template:  '{{ record.action }}'
  attribute :user_ip, template:  '{{ record.user_ip }}'

end
