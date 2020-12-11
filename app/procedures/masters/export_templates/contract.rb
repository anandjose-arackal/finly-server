class Masters::ExportTemplates::Contract < Reform::Form
  property :name, validates: { presence: true }
  property :description, validates: { presence: true }
  property :export_format, validates: { presence: true, inclusion: { in: Masters::ExportTemplates::Helpers::Config.export_formats } }
  property :resource, validates: { presence: true, inclusion: { in: Masters::ExportTemplates::Helpers::Config.resources } }
  property :template, validates: { presence: true }
  property :query, default: {}
  property :active, default: true
  property :personal, default: true
  property :created_by_id
  property :company_id, validates: { presence: true }

  # collection :role_mappings, populate_if_empty: ExportTemplateUserRoleMapping do
  #   property :user_role_id, validates: {presence: true}
  # end

  validate :validate_template

  def validate_template
    if ['xls', 'csv'].include?(self.export_format)
      begin
        parsed_template = JSON.parse(self.template)
      rescue
        errors.add :base, 'Invalid template'
        return
      end

      unless parsed_template["columns"].present?
        errors.add :base, 'Invalid template'
        return
      end

      unless parsed_template["columns"].count
        errors.add :base, 'Invalid template'
        return
      end

      parsed_template["columns"].each do |column|
        unless column["label"].present?
          errors.add :base, "Label cannot be empty"
          return
        end
      end

      true
    end
  end
end
