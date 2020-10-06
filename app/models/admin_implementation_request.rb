# == Schema Information
#
# Table name: admin_implementation_requests
#
#  id                        :bigint           not null, primary key
#  company_id                :integer          not null
#  admin_user_id             :integer          not null
#  request_key               :string(255)      not null
#  request_params            :text(4294967295)
#  master                    :string(255)
#  name                      :string(255)
#  status                    :integer          not null
#  message                   :text(65535)
#  started_at                :datetime
#  completed_at              :datetime
#  runtime                   :decimal(10, )
#  requested_items           :integer
#  completed_items           :integer
#  request_file_file_name    :string(255)
#  request_file_content_type :string(255)
#  request_file_file_size    :bigint
#  request_file_updated_at   :datetime
#  result_file_file_name     :string(255)
#  result_file_content_type  :string(255)
#  result_file_file_size     :bigint
#  result_file_updated_at    :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  success_items             :integer          default(0)
#  failed_items              :integer          default(0)
#  deleted_at                :datetime
#

class AdminImplementationRequest < NonTenantedApplicationRecord
  belongs_to :company
  belongs_to :admin_user

  scope :with_request_key, ->(request_key) { where request_key: request_key }
  default_scope {order(created_at: :desc)}
  before_save do
    if self.started_at.present? and self.completed_at.present? and self.runtime.blank?
      self.runtime = self.completed_at - self.started_at
    end
  end

  enum status: [:pending, :in_progress, :completed, :failed, :error]

  serialize :request_params, JSON

  has_attached_file :request_file, :use_timestamp => false
  do_not_validate_attachment_file_type :request_file
  # validates_attachment_file_name :request_file, matches: [/\.xls?$/, /\. xlsx?$/, /\.csv?$/]

  has_attached_file :result_file, :use_timestamp => false
  do_not_validate_attachment_file_type :result_file
  # validates_attachment_file_name :result_file, matches: [/\.xls?$/, /\. xlsx?$/, /\.csv?$/]
end
