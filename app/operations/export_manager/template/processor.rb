class ExportManager::Template::Processor
  include DynamicAttributes
  include ExportManager::DSL::Job

  attr_accessor :current_record

  def initialize(export_job)
    self.export_job = export_job
  end

  def update_current_record
    return unless current_record

    update record: current_record
  end

end