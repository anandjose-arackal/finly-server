module ExportManager::Builders::Template::DSL
  extend ActiveSupport::Concern

  class_methods do

    def attribute(name, template:, column_name: nil)
      columns << ExportManager::Builders::Template::Attribute.new(
        {
          name: name,
          template: template,
          column_name: column_name
        }
      )
    end

    def columns
      @columns ||= []
    end

    def custom_fields(field_parent_type, template_prefix:)
      custom_fields_config << {
        key: field_parent_type,
        form: false,
        template_prefix: template_prefix
      }.with_indifferent_access
    end

    def form_custom_fields(form_route, template_prefix:)
      custom_fields_config << {
        key: form_route,
        form: true,
        template_prefix: template_prefix
      }.with_indifferent_access
    end

    def custom_fields_config
      @custom_fields_config ||= []
    end

  end
end
