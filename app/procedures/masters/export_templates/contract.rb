class Masters::ExportTemplates::Contract < Reform::Form
  property :name, validates: { presence: true }
  property :description, validates: { presence: true }
  property :export_format, validates: { presence: true, inclusion: { in: Masters::ExportTemplates::Helpers::Config.export_formats } }
  property :resource, validates: { presence: true, inclusion: { in: Masters::ExportTemplates::Helpers::Config.resources } }
  property :template, validates: { presence: true }
  property :query, validates: { presence: true }
  property :active, default: true
  property :personal, default: true
  property :created_by_id, validates: { presence: true }
  property :company_id, validates: { presence: true }
  property :include_custom_fields
end
