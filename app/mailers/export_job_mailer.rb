class ExportJobMailer < ApplicationMailer

  def success(export_job_id)
    export_job = ExportJob.find_by id: export_job_id
    return unless export_job&.status_id == ExportJobStatus.id_for(:completed)
    return unless export_job&.created_by&.email.present?

    @url = "#{export_job.attachment.url}"
    mail to: export_job.created_by.email, subject: "[Success] Export of #{export_job.name}", template_name: 'success_template'
  end

  def failure(export_job_id)
    export_job = ExportJob.find_by id: export_job_id
    return unless export_job&.status_id == ExportJobStatus.id_for(:failed)
    return unless export_job&.created_by&.email.present?

    mail to: export_job.created_by.email, subject: "[Failed] Export of #{export_job.name}", template_name: 'failure_template'
  end

end
