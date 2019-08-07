class AdminImplementationRequest < ApplicationRecord
  belongs_to :company
  belongs_to :admin_user

  enum status: [:pending, :in_progress, :completed, :failed, :error]

  serialize :request_params, JSON

  has_attached_file :request_file, :use_timestamp => false
  validates_attachment_file_name :request_file, matches: [/\.xls?$/, /\. xlsx?$/, /\.csv?$/]

  has_attached_file :result_file, :use_timestamp => false
  validates_attachment_file_name :result_file, matches: [/\.xls?$/, /\. xlsx?$/, /\.csv?$/]
end
