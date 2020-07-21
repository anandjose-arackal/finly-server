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

  has_many :jobs, class_name: 'MacroJob'
  has_many :schedules, class_name: 'MacroSchedule'
  has_many :routes, class_name: 'MacroRoute'

  scope :active, -> { where(active: true).where('start_date >= ? and end_date <= ?', DateTime.now, DateTime.now)}
  scope :with_route, -> (route) { joins(:routes).where(macro_routes: {route: route}) }

  serialize :permissions, JSON

  def as_json(options={})
    {
        id: id,
        macro_key: macro_key,
        name: name,
        description: description,
        script: script,
        macro_type: macro_type.as_json,
        active: active,
        user: (user&.email || user&.mobile_number),
        created_by_admin: created_by_admin.as_json,
        start_date: start_date,
        end_date: end_date,
        permissions: permissions,
        last_run_at: last_run_at,
        schedules: schedules.as_json(options),
        routes: routes.as_json(options),
        company: company.as_json(options)
    }
  end

end
