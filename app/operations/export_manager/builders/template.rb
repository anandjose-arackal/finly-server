class ExportManager::Builders::Template
  include EventBus::Subscriber
  include DynamicAttributes
  include DSL

  bus ExportManager::TemplateMaster

  class_attr :label
  class_attr :description
  class_attr :export_format
  class_attr :resource
  class_attr :default, default: false
  class_attr :query, default: {}
  class_attr :roles, default: []

  def self.master
    self.to_s
  end

  def self.build_custom_columns(company)
    cols = []
    custom_fields_config.each do |config|
      if config[:form]
        form = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(config[:key])&.name, company_id: company.id)
        if form.present?
          custom_entities = form.entities.where(system_field: false)
          custom_entities.each do |entity|
            cols << ExportManager::Builders::Template::Attribute.new(
              {
                name: entity.entity_key.to_sym,
                template: "{{ #{config[:template_prefix]}.#{entity.entity_key} }}",
                column_name: entity.label
              }
            )
          end
        end
      else
        fields = FieldConfiguration.where(company_id: company.id).joins(:field_parent_mappings).where('field_parent_mappings.field_parent_type_id = ?', FieldParentType.id_for(config[:key]))
        fields.each do |field|
          cols << ExportManager::Builders::Template::Attribute.new(
            {
              name: field.field_key&.to_sym,
              template: "{{ #{config[:template_prefix]}.#{field.field_key} }}",
              column_name: field.field_name
            }
          )
        end
      end
    end

    cols
  end

  def self.build(company)
    cols = columns + build_custom_columns(company)
    {
      name: label,
      description: description,
      resource: resource,
      export_format: export_format,
      template: JSON.generate({
        columns: cols.map do |attr|
          attr.build
        end
      }),
      query: query,
      default: default,
      master: master,
      personal: false,
      user_roles: roles.map do |role|
        {
          "user_role_id": UserRole.id_for(role)
        }
      end
    }
  end

  def self.create_or_update_template!(company)
    existing_template = ExportTemplateNew.where(master: master, company_id: company.id).first
    data = build(company)
    user_roles = data.delete(:user_roles)
    if existing_template.present?
      unless existing_template.modified
        existing_template.role_mappings.destroy_all
        existing_template.update!(**data)
        existing_template.role_mappings.create!(user_roles)
      end
    else
      export_template = ExportTemplateNew.create!(**data, company_id: company.id)
      export_template.role_mappings.create!(user_roles)
    end
  end

  def self.update_template_for_all!
    Company.find_each do |company|
      create_or_update_template!(company)
    end
  end
end
