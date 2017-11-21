# == Schema Information
#
# Table name: user_role_mappings
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  user_role_id :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  purpose_id   :integer
#







class UserRoleMapping < ActiveRecord::Base

  belongs_to :user
  belongs_to :user_role
  belongs_to :purpose, class_name: "Purpose"

  scope :role, ->(role_id) { where user_role_id: role_id }
  scope :admin, -> { where(user_role_id: UserRole.id_for(:admin)) }
  scope :finance_manager, -> { where(user_role_id: UserRole.id_for(:finance_manager)) }
  scope :manager, -> { where(user_role_id: UserRole.manager_id) }
  scope :initiator, -> {where user_role_id: UserRole.id_for(:initiator)}
  scope :auditor, -> { where(user_role_id: UserRole.id_for(:auditor)) }
  scope :employee, -> { where(user_role_id: UserRole.id_for(:employee)) }
  scope :without_employee, -> {where.not(user_role_id: UserRole.id_for(:employee))}
  scope :only_admin_and_finance, -> {where(user_role_id: [UserRole.id_for(:admin), UserRole.id_for(:finance_manager)])}
  scope :vendor_payments, -> { where purpose_id: Purpose.id_for(:vendor_payments)}
  scope :expense_management, -> { where purpose_id: Purpose.id_for(:expense_management)}
  scope :with_purpose, -> (purpose_id) { where purpose_id: purpose_id}

  before_destroy do
    employee_role_presence
  end

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

  private

  def employee_role_presence
    unless self.user.role_mapping.employee.present?
      errors.add(:employee, "role cannot be removed for a user")
    end
  end
end
