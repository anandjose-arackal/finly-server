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
#

class ExportJob < ApplicationRecord
  belongs_to :status, class_name: 'ExportJobStatus'
  belongs_to :created_by, optional: true, class_name: 'User'

  has_attached_file :attachment, :use_timestamp => false
  do_not_validate_attachment_file_type :attachment

  scope :created_after, -> (datetime) { where 'created_at > ?', datetime}

  serialize :request_params, JSON

  default_scope {order(created_at: :desc)}

  def progress_changed(completed)
    update completed_records: completed
  end

  def pending!
    update status_id: ExportJobStatus.id_for(:pending)
  end

  def pending?
    status_id == ExportJobStatus.id_for(:pending)
  end

  def in_progress!
    update status_id: ExportJobStatus.id_for(:in_progress)
  end

  def in_progress?
    status_id == ExportJobStatus.id_for(:in_progress)
  end

  def success!(attachment = nil)
    update status_id: ExportJobStatus.id_for(:success), attachment: attachment
  end

  def success?
    status_id == ExportJobStatus.id_for(:success)
  end

  def failed!
    update status_id: ExportJobStatus.id_for(:failed)
  end

  def failed?
    status_id == ExportJobStatus.id_for(:failed)
  end

  def as_json(options={})
    {
        id: id,
        name: name,
        export_type: export_type,
        created_by_id: created_by_id,
        completed_at: completed_at&.strftime("%Y-%m-%d  %H:%M:%S"),
        total_records: total_records,
        completed_records: completed_records,
        completion_percentage: completion_percentage,
        attachment: attachment&.url,
        created_at: created_at&.strftime("%Y-%m-%d  %H:%M:%S"),
        status: status&.name,
    }
  end

end
