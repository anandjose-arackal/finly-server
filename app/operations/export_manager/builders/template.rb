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

  def self.build
    {
      name: label,
      description: description,
      resource: resource,
      export_format: export_format,
      template: JSON.generate({
        columns: columns.map do |attr|
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
    data = build
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
