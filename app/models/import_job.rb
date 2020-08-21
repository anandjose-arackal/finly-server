# == Schema Information
#
# Table name: import_jobs
#
#  id                      :bigint           not null
#  uuid                    :string(36)       not null, primary key
#  name                    :string(255)      not null
#  type                    :string(255)
#  created_by_id           :integer
#  company_id              :bigint           not null
#  request_params          :text(4294967295)
#  completed_at            :datetime
#  total_records           :integer
#  created_records         :integer
#  updated_records         :integer
#  skipped_records         :integer
#  failed_records          :integer
#  completed_records       :integer
#  completion_percentage   :integer
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :bigint
#  attachment_updated_at   :datetime
#  deleted_at              :datetime
#  options                 :text(4294967295)
#  description             :string(255)
#  crash_stacktrace        :text(4294967295)
#  status_id               :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class ImportJob < ApplicationRecord
  include UUIDHelper

  belongs_to :created_by, class_name: 'User'
  belongs_to :company
  belongs_to :status, class_name: 'ImportJobStatus'

  scope :with_status_id, ->(status_id) {
    where status_id: status_id
  }

  ransack_scopes :with_status_id

  has_attached_file :attachment, :use_timestamp => false
  validates_attachment_content_type :attachment,
                                    content_type: %w(application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet text/csv text/plain)

  serialize :request_params, JSON
  serialize :options, JSON

  def to_exposure
    ImportJobExposure.new(self)
  end

end
