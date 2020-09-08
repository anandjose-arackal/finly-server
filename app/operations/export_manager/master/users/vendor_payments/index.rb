class ExportManager::Master::Users::VendorPayments::Index < ExportManager::Builders::Template

  label 'Export'
  description 'Users Export'
  export_format 'csv'
  resource 'users'
  subscribe 'users'
  default true

  attribute :employee_id, template: '{{ record.profile.employee_id }}'
  attribute :name, template: '{{ record.name }}'
  attribute :email, template: '{{ record.email }}'
  attribute :mobile_number, template: '{{ record.mobile_number }}'
  attribute :status, template: '{{ record.active }}'

  # def input
  #   resolve('users.default').includes(:profile)
  # end


  # def employee_id(user)
  #   user.profile&.employee_id.to_s
  # end

  # def name(user)
  #   user.name
  # end

  # def email(user)
  #   user.email
  # end

  # def mobile_number(user)
  #   user.mobile_number
  # end

  # def status(user)
  #   user.active
  # end


end