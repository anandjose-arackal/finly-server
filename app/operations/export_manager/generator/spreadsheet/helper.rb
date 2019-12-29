module ExportManager::Generator::Spreadsheet::Helper
  extend ActiveSupport::Concern

  class_methods do
    def attribute(name, column_name: nil, dynamic: false)
      attributes << ExportManager::Generator::Spreadsheet::Attribute.new({name: name, column_name: column_name, dynamic: dynamic})
    end

    def attributes
      @attributes ||= []
    end
  end

end