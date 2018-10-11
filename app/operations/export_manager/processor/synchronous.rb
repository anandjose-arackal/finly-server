class ExportManager::Processor::Synchronous < ExportManager::Processor::Base

  def valid?
    if self.generator.blank? or self.master.blank?
      add_message :error, 'Error loading configuration'
      return
    end
  end

  def run
    generator.run
  end

end