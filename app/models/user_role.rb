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

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def id_for(role)
    VALUES[role]
  end

end
