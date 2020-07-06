# == Schema Information
#
# Table name: macros
#
#  id                  :bigint           not null, primary key
#  macro_id            :string(255)      not null
#  name                :string(255)      not null
#  description         :text(65535)
#  script              :text(65535)      not null
#  macro_type_id       :integer          not null
#  active              :boolean
#  company_id          :integer
#  user_id             :integer          not null
#  created_by_id       :integer
#  created_by_admin_id :integer
#  last_run_at         :datetime
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Macro < FinlyMacrosRecord
  belongs_to :macro_type

  has_many :jobs, class_name: 'MacroJob'
  has_many :schedules, class_name: 'MacroSchedule'
  belongs_to :user
  belongs_to :company
  belongs_to :created_by, class_name: 'User'
  belongs_to :created_by_admin, class_name: 'AdminUser'

end
