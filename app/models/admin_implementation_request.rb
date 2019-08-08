class AdminImplementationRequest < ApplicationRecord
  belongs_to :company
  belongs_to :admin_user

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
