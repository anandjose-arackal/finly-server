class ExportManager::Generator::Spreadsheet < ExportManager::Generator::Base
  attr_accessor :header

  type :spreadsheet

  def self.setup(master_class)
    master_class.include ExportManager::Generator::Spreadsheet::Builder
  end

  def self.config(master_class)
    master_class.attributes.as_json
  end

  def perform
    file = master.build(self)
    self.save_attachment file
    self.success!
    file
  end

end