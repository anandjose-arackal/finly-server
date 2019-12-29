class ExportManager::Generator::Spreadsheet < ExportManager::Generator::Base

  type :spreadsheet

  def self.setup(master_class)
    master_class.include Helper
  end

  def self.config(master_class)
    master_class.attributes.as_json
  end

  def perform
    builder = Builder.new(self)
    builder.build
  end

end