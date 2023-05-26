# == Schema Information
#
# Table name: approval_tat_report_exec_logs
#
#  id                      :bigint           not null, primary key
#  company_id              :integer          not null
#  user_id                 :integer          not null
#  document_type           :string(255)
#  record_count            :integer
#  output_count            :integer
#  start_time              :datetime
#  end_time                :datetime
#  total_time_sec          :integer
#  filter_json             :string(255)
#  job_status              :string(255)
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class ApprovalTatReportExecLog < ApplicationRecord

end
