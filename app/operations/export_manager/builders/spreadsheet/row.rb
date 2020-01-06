class ExportManager::Builders::Spreadsheet::Row
  attr_accessor :record, :header

  def initialize(record:, header:)
    self.record = record
    self.header = header
  end

  def values
    @values ||= {}
  end

  def add(column, value)
    header.add column
    values[column&.to_s] = value&.to_s
  end

  def build
    data = []
    header.list.each do |column|
      data << values[column]
    end
    data
  end

end