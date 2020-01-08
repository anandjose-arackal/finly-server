class ExportManager::Builders::Spreadsheet::Attribute

  attr_accessor :name, :column_name, :dynamic, :default, :section

  def initialize(name:, column_name: nil, dynamic: false, default: true, section: nil)
    self.name = name
    self.column_name = column_name || name.to_s.humanize
    self.dynamic = dynamic
    self.default = default
    self.section = section
  end

  def as_json(options = {})
    {
        name: name,
        column_name: column_name,
        default: default,
    }
  end

end