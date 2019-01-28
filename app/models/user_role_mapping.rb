# == Schema Information
#
# Table name: user_role_mappings
#
#  id                    :integer          not null, primary key
#  user_id               :integer          not null
#  user_role_id          :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  purpose_id            :integer
#  company_department_id :integer
#  branch_location_id    :integer
#

class UserRoleMapping < ApplicationRecord

  belongs_to :user, optional: true
  belongs_to :user_role, optional: true
  belongs_to :company_department, optional: true
  belongs_to :branch_location, optional: true
  belongs_to :purpose, optional: true, class_name: "Purpose"

  scope :role, ->(role_id) { where user_role_id: role_id }
  scope :admin, -> { where(user_role_id: UserRole.id_for(:admin)) }
  scope :finance_manager, -> { where(user_role_id: UserRole.id_for(:finance_manager)) }
  scope :manager, -> { where(user_role_id: UserRole.manager_id) }
  scope :travel_manager, -> { where user_role_id: UserRole.id_for(:travel_manager) }
  scope :initiator, -> {where user_role_id: UserRole.id_for(:initiator)}
  scope :creditor, -> { where user_role_id: UserRole.id_for(:creditor) }
  scope :auditor, -> { where(user_role_id: UserRole.id_for(:auditor)) }
  scope :employee, -> { where(user_role_id: UserRole.id_for(:employee)) }
  scope :without_employee, -> {where.not(user_role_id: UserRole.id_for(:employee))}
  scope :only_admin_and_finance, -> {where(user_role_id: [UserRole.id_for(:admin), UserRole.id_for(:finance_manager)])}
  scope :vendor_payments, -> { where purpose_id: Purpose.id_for(:vendor_payments)}
  scope :expense_management, -> { where purpose_id: Purpose.id_for(:expense_management)}
  scope :invoicing, -> { where purpose_id: Purpose.id_for(:invoice)}
  scope :with_purpose, -> (purpose_id) { where purpose_id: purpose_id}
  scope :reviewer_mappings_only, -> { where user_role_id: [UserRole.id_for(:manager), UserRole.id_for(:finance_manager), UserRole.id_for(:reviewer), UserRole.id_for(:creditor)] }

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
