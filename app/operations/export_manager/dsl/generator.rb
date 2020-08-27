module ExportManager::DSL::Generator
  extend ActiveSupport::Concern

  class Background < BackgroundOperation
    def process
      export_job = ExportJob.find_by(id: params[:export_job_id])
      master_class = Object.const_get(export_job.master)
      master = master_class.new(export_job.created_by, export_job.request_params.with_indifferent_access)
      master.export_job = export_job
      master.build
    end
  end

  included do
    class_attr :sync, default: false
  end

  class_methods do
    def sync!
      sync(true)
    end

    def sync?
      sync
    end
  end

  def sync?
    self.class.sync
  end

  def perform
    return unless valid?

    create_job
    if sync?
      build
    else
      Background.call_async(user, {export_job_id: self.export_job.id})
    end
  end

  def build
    update status_id: ExportJobStatus.id_for(:in_progress)
    begin
      pre_process!
      generate
      post_process!
    rescue Exception => e
      update_current_record
      stack_trace = "#{e.message}\n#{e.backtrace.join("\n")}"
      update crash_stacktrace: stack_trace, status_id: ExportJobStatus.id_for(:failed), message: "Exception: #{e.message}"
      raise e
    end
  end

  def generate

  end

  def update_current_record
  
  end

end