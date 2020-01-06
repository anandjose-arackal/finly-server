class ExportManager::Builders::Spreadsheet::Section

  attr_accessor :name, :attributes

  def initialize(name:)
    self.name = name
  end

  def attributes
    @attributes ||= []
  end

  def add(attribute)
    return unless attribute

    attributes << attribute
  end

  def as_json(options = {})
    {
        section: name,
        attributes: attributes.as_json
    }
  end

end