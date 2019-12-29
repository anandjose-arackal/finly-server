class ExportManager::Generator::Spreadsheet < ExportManager::Generator::Base

  def self.setup(master_class)
    master_class.include Helper
  end

  def perform
    builder = Builder.new(self)
    builder.build
  end

end