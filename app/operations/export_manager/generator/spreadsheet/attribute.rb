class ExportManager::Generator::Spreadsheet::Attribute

  attr_accessor :name, :column_name, :dynamic, :default

  def initialize(name:, column_name: nil, dynamic: false, default: true)
    self.name = name
    self.column_name = column_name || name.to_s.humanize
    self.dynamic = dynamic
    self.default = default
  end

end