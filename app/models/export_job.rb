# == Schema Information
#
# Table name: export_jobs
#
#  id                      :bigint           not null, primary key
#  name                    :string(255)      not null
#  export_type             :string(255)
#  created_by_id           :integer
#  completed_at            :datetime
#  total_records           :integer
#  completed_records       :integer
#  completion_percentage   :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :bigint
#  attachment_updated_at   :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  status_id               :integer          not null
#  company_id              :bigint           not null
#  request_params          :text(4294967295)
#  deleted_at              :datetime
#  master                  :string(255)
#  description             :string(255)
#  processing_record_type  :string(255)
#  processing_record_id    :bigint
#  record_type             :string(255)
#  record_id               :bigint
#  crash_stacktrace        :text(65535)
#  message                 :text(65535)
#  note                    :text(65535)
#

class ExportJob < ApplicationRecord
  include SoftDeletable

  belongs_to :status, class_name: 'ExportJobStatus'
  belongs_to :created_by, optional: true, class_name: 'User'
  belongs_to :record, polymorphic: true, optional: true

  has_attached_file :attachment, :use_timestamp => false
  do_not_validate_attachment_file_type :attachment

  scope :created_after, -> (datetime) {where 'created_at > ?', datetime}

  serialize :request_params, JSON

  default_scope {order(created_at: :desc)}

  def pending?
    status_id == ExportJobStatus.id_for(:pending)
  end

  def in_progress?
    status_id == ExportJobStatus.id_for(:in_progress)
  end

  def success?
    status_id == ExportJobStatus.id_for(:completed)
  end

  def failed?
    status_id == ExportJobStatus.id_for(:failed)
  end

  def retry
    return false unless failed?

    ExportManager::DSL::Generator::Background.call_async(user, {export_job_id:self.id})
    true
  end

  def as_json(options = {})
    {
        id: id,
        name: name,
        export_type: export_type,
        completed_at: completed_at&.strftime("%I:%M%p, %d-%m-%Y"),
        total_records: (total_records || 0),
        completed_records: (completed_records || 0),
        completion_percentage: (completion_percentage || 0),
        attachment: attachment&.url,
        created_at: created_at&.strftime("%I:%M%p, %d-%m-%Y"),
        status: status&.name,
        note: note
    }
  end

end
