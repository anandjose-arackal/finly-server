# == Schema Information
#
# Table name: macros
#
#  id                  :bigint           not null, primary key
#  name                :string(255)      not null
#  description         :text(65535)
#  script              :text(65535)      not null
#  macro_type_id       :integer          not null
#  active              :boolean
#  start_date          :date
#  end_date            :date
#  company_id          :integer
#  user_id             :integer          not null
#  created_by_id       :integer
#  created_by_admin_id :integer
#  long_running_job    :boolean
#  last_run_at         :datetime
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Macro < FinlyMacrosRecord
  belongs_to :macro_type
  belongs_to :user
  belongs_to :company
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :created_by_admin, class_name: 'AdminUser'

  has_many :jobs, class_name: 'MacroJob'
  has_many :schedules, class_name: 'MacroSchedule'
  has_many :routes, class_name: 'MacroRoute'

  scope :active, -> { where(active: true).where('start_date >= ? and end_date <= ?', DateTime.now, DateTime.now)}

  serialize :permissions, JSON

  def as_json(options={})
    {
        id: id,
        macro_id: macro_id,
        name: name,
        description: description,
        script: script,
        macro_type: macro_type.as_json,
        active: active,
        user: user.as_json,
        created_by_admin: created_by_admin.as_json,
        last_run_at: last_run_at,
        schedules: schedules.as_json(options)
    }
  end

end
