class ExportManager::Generator::Spreadsheet::Attribute

  attr_accessor :name, :column_name, :dynamic

  def initialize(name:, column_name: nil, dynamic: false)
    self.name = name
    self.column_name = column_name || name.to_s.humanize
    self.dynamic = dynamic
  end

end