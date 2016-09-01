# == Schema Information
#
# Table name: user_roles
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserRole < ActiveRecord::Base
  has_many :users, through: :user_role_mappings

  scope :admin, -> { where(id: UserRole.admin_id) }
  scope :finance_manager, -> { where(id: UserRole.finance_manager_id) }
  scope :manager, -> { where(id: UserRole.manager_id) }
  scope :employee, -> { where(id: UserRole.employee_id) }
  scope :auditor, -> { where(id: UserRole.auditor_id) }

  VALUES = {admin: 1, finance_manager: 2, manager: 3, employee: 4, auditor: 5}

  def self.admin_id
    1
  end

  def self.finance_manager_id
    2
  end

  def self.manager_id
    3
  end

  def self.employee_id
    4
  end

  def self.auditor_id
    5
  end

end
