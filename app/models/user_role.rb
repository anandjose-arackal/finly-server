class UserRole < ActiveRecord::Base
  has_many :users, through: :user_role_mappings

  scope :admin, -> { where(id: 1) }
  scope :finance_manager, -> { where(id: 2) }
  scope :manager, -> { where(id: 3) }
  scope :employee, -> { where(id: [1, 2, 3, 4]) }
  scope :auditor, -> { where(id: 5) }
end