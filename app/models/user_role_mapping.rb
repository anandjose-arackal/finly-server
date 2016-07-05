class UserRoleMapping < ActiveRecord::Base
  include PolicyVersion

  belongs_to :user
  belongs_to :user_role
  belongs_to :policy

  scope :role, ->(role_id) { where user_role_id: role_id }
  scope :policy, ->(policy_id) { where policy_id: policy_id }
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
