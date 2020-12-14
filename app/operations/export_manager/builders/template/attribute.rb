class ExportManager::Builders::Template::Attribute
  attr_accessor :name, :template, :column_name

  def initialize(name:, template:, column_name: nil)
    self.name = name
    self.template = template
    self.column_name = column_name || name.to_s.humanize
  end

  def build
    {
        label: column_name,
        value: template
    }
  end

end