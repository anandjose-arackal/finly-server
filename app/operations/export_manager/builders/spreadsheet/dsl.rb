module ExportManager::Builders::Spreadsheet::DSL
  extend ActiveSupport::Concern

  class_methods do
    def section(name, &block)
      @section = ExportManager::Builders::Spreadsheet::Section.new(name: name)
      sections << @section
      block.call
      @section = nil
    end

    def attribute(name, column_name: nil, dynamic: false, default: true)
      section = @section || default_section
      attr = ExportManager::Builders::Spreadsheet::Attribute.new(
          {
              name: name,
              column_name: column_name,
              section: section,
              dynamic: dynamic,
              default: default,
          }
      )
      section&.add attr
      attributes << attr
    end

    def sections
      @sections ||= [default_section]
    end

    def default_section
      @default_section ||= ExportManager::Builders::Spreadsheet::Section.new(name: :default)
    end

    def attributes
      @attributes ||= []
    end
  end
end