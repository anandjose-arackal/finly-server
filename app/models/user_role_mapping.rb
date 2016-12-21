# == Schema Information
#
# Table name: user_role_mappings
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  user_role_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#


class UserRoleMapping < ActiveRecord::Base

  belongs_to :user
  belongs_to :user_role

  scope :role, ->(role_id) { where user_role_id: role_id }
  scope :admin, -> { where(user_role_id: UserRole.admin_id) }
  scope :finance_manager, -> { where(user_role_id: UserRole.finance_manager_id) }
  scope :manager, -> { where(user_role_id: UserRole.manager_id) }
  scope :employee, -> { where(user_role_id: UserRole.employee_id) }
  scope :auditor, -> { where(user_role_id: UserRole.auditor_id) }

  def is_admin?
    self.user_role_id == UserRole.admin_id
  end

  def is_finance_manager?
    self.user_role_id == UserRole.finance_manager_id
  end

  def is_manager?
    self.user_role_id == UserRole.manager_id
  end

  def is_employee?
    self.user_role_id == UserRole.employee_id
  end

  def is_auditor?
    self.user_role_id == UserRole.auditor_id
  end
end
