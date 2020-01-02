class ExportManager::Processor::Synchronous < ExportManager::Processor::Base

  def run
    master = master_class.new(user, params)
    master_class.generator.build(master).run
  end

end