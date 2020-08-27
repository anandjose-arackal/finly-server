module ExportManager::DSL::Job
  extend ActiveSupport::Concern

  included do
    attr_accessor :export_job
    class_attr :job_name
  end

  def create_job
    name = build_name || "Export"
    self.export_job = user.export_jobs.create(
        {
            name: name,
            export_type: nil,
            total_records: 0,
            completed_records: 0,
            company_id: user.company_id,
            note: params[:note],
            request_params: params,
            master: self.class.name,
            description: self.class.description,
            status_id: ExportJobStatus.id_for(:pending)
        }
    )
  end

  def build_name
    return (self.class.description || self.class.label) unless self.class.job_name

    job_name = self.class.job_name
    if job_name.class.name == Proc.name
      job_name.call(user, params, data)
    elsif job_name.class.name == Symbol.name
      send(job_name)
    else
      job_name
    end
  end

  def update(params)
    export_job.update params
  end

  def progress_update(completed, force_update: true)
    return unless (completed % 100).zero? || force_update

    export_job.update(completed_records: completed, completion_percentage: (completed * 100 / export_job.total_records))
  end

  def save_attachment(file)
    export_job.update(attachment: file)
  end

  def success!
    export_job.update(status_id: ExportJobStatus.id_for(:completed), completed_at: DateTime.now, completion_percentage: 100)
    ExportJobMailer.delay.success(export_job.id)
  end

  def failure!
    export_job.update(status_id: ExportJobStatus.id_for(:failed), completed_at: DateTime.now)
    ExportJobMailer.delay.failure(export_job.id)
  end

end