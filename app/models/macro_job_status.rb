# == Schema Information
#
# Table name: macro_job_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MacroJobStatus < FinlyMacrosRecord
  include Seedable

  set_values :in_progress, :completed

end
