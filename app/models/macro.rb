# == Schema Information
#
# Table name: macros
#
#  id                  :bigint           not null, primary key
#  macro_key           :string(255)      not null
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
#  permissions         :text(65535)
#

class Macro < FinlyMacrosRecord
  include Sequenced::ActsAsSequenced

  acts_as_sequenced column: :macro_key, purpose: :macro, editable: false, prefix: 'MACRO/'

  belongs_to :macro_type
  belongs_to :user
  belongs_to :company
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :created_by_admin, class_name: 'AdminUser'

  has_one :job, class_name: "MacroJob"
  has_many :jobs, class_name: 'MacroJob'
  has_many :schedules, class_name: 'MacroSchedule'
  has_many :routes, class_name: 'MacroRoute'

  scope :active, -> (value = true) do
    filter_active(value)
  end
  scope :filter_active, -> (value = true) {
    if [99, 'active', true].include?(value)
      where(active: true).where('(start_date IS NULL OR start_date <= ?) AND (end_date IS NULL OR end_date >= ?)', Date.today, Date.today)
    elsif [98, 'inactive', false].include?(value)
      where('active = FALSE OR active IS NULL OR start_date > ? OR end_date < ?', Date.today, Date.today)
    end
  }
  scope :with_route, -> (route) {joins(:routes).where(macro_routes: {route: route})}

  serialize :permissions, JSON

  default_scope {order(created_at: :desc)}

  ransack_scopes :filter_active

  def active?
    return false if start_date.present? and start_date > Date.today
    return false if end_date.present? and end_date < Date.today
    return false unless active

    true
  end

  def as_json(options = {})
    {
        id: id,
        macro_key: macro_key,
        name: name,
        description: description,
        script: script,
        macro_type: macro_type.as_json,
        active: active,
        long_running_job: long_running_job,
        company: company.as_json(options),
        user: (user&.email || user&.mobile_number),
        created_by_admin: created_by_admin.as_json,
        start_date: start_date,
        end_date: end_date,
        permissions: permissions,
        last_run_at: last_run_at,
        schedules: schedules.as_json(options),
        routes: routes.as_json(options),
    }
  end

end
