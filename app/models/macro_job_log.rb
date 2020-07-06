# == Schema Information
#
# Table name: macro_job_logs
#
#  id           :bigint           not null, primary key
#  macro_id     :integer          not null
#  macro_job_id :integer          not null
#  log_type     :string(255)
#  message      :text(65535)
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MacroJobLog < FinlyMacrosRecord
  belongs_to :macro
  belongs_to :macro_job
end
