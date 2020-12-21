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
  end
end
