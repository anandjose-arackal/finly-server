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
      query: JSON.generate(query),
      default: default,
      master: master,
    }
  end

  def self.update_template!
    Company.find_each do |company|
      ExportTemplateNew.where(company_id: company.id, master: master, modified: false).find_each do |export_template|
        export_template.update(**build)
      end
    end
  end
end
