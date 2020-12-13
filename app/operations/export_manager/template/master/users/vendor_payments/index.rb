class ExportManager::Template::Master::Users::VendorPayments::Index < ExportManager::Builders::Template

  label 'Export'
  description 'Users Export'
  export_format 'xls'
  resource 'users'
  subscribe 'users'
  default true

  attribute :employee_id, template: '{{ record.profile.employee_id }}'
  attribute :name, template: '{{ record.name }}'
  attribute :email, template: '{{ record.email }}'
  attribute :mobile_number, template: '{{ record.mobile_number }}'
  attribute :status, template: '{{ record.active }}'
end
