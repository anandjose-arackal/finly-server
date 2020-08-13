# == Schema Information
#
# Table name: macro_job_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MacroJobStatus < FinlyMacrosRecord
  include Seedable

  def self.values
    [:in_progress, :completed, :failed]
  end

  def as_json(options={})
    {
        id: id,
        name: name.titleize
    }
  end

end
