class ExportTemplates::Contract < Reform::Form

  property :name, validates: {presence: true}
  property :description, validates: {presence: true}
  property :template_type, validates: {presence: true, inclusion: {in: ExportTemplates::Helpers::Config.types}}
  property :configuration, validates: {presence: true}
  property :model_klass, validates: {presence: true}
  property :active, default: true
  property :personal, default: true
  property :created_by_user_id, validates: {presence: true}
  property :company_id, validates: {presence: true}

  validate :validate_configuration

  def validate_configuration
    schema_contract = ExportTemplates::Helpers::Config.contract_for(self.template_type)
    if schema_contract.nil?
      errors.add :base, 'Schema contract not found'
      return
    end

    result = schema_contract.call self.configuration
    add_schema_errors(result.errors) unless result.success?
  end
end