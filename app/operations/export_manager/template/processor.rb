class ExportManager::Template::Processor
  include DynamicAttributes
  include ExportManager::DSL::Job

  def initialize(export_job)
    self.export_job = export_job
  end

end