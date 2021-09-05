# == Schema Information
#
# Table name: import_jobs
#
#  id                       :bigint           not null
#  uuid                     :string(36)       not null, primary key
#  name                     :string(255)      not null
#  type                     :string(255)
#  created_by_id            :integer
#  company_id               :bigint           not null
#  request_params           :text(4294967295)
#  completed_at             :datetime
#  total_records            :integer
#  created_records          :integer
#  updated_records          :integer
#  skipped_records          :integer
#  failed_records           :integer
#  completed_records        :integer
#  completion_percentage    :integer
#  attachment_file_name     :string(255)
#  attachment_content_type  :string(255)
#  attachment_file_size     :bigint
#  attachment_updated_at    :datetime
#  deleted_at               :datetime
#  options                  :text(4294967295)
#  description              :string(255)
#  crash_stacktrace         :text(4294967295)
#  status_id                :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  result_file_file_name    :string(255)
#  result_file_content_type :string(255)
#  result_file_file_size    :bigint
#  result_file_updated_at   :datetime
#

class ImportJob < ApplicationRecord
  include UUIDHelper
  include Exposures::Model::Exposable

  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :company
  belongs_to :status, class_name: 'ImportJobStatus'

  scope :with_status_id, ->(status_id) {
    where status_id: status_id
  }

  ransack_scopes :with_status_id

  has_attached_file :attachment, :use_timestamp => false
  validates_attachment :attachment, content_type: {content_type: []}

  has_attached_file :result_file, :use_timestamp => false
  validates_attachment :result_file, content_type: {content_type: []}

  serialize :request_params, JSON
  serialize :options, JSON

  def as_json(options = {})
    {
      id: id,
      name: name,
      description: description,
      type: type,
      completed_at: completed_at&.strftime("%I:%M%p, %d-%m-%Y"),
      total_records: (total_records || 0),
      created_records: (created_records || 0),
      updated_records: (updated_records || 0),
      skipped_records: (skipped_records || 0),
      failed_records: (failed_records || 0),
      completed_records: (completed_records || 0),
      completion_percentage: (completion_percentage || 0),
      attachment: attachment&.url,
      result_file: result_file&.url,
      created_at: created_at&.strftime("%I:%M%p, %d-%m-%Y"),
      status: status&.name
    }
  end

end
