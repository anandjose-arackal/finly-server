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

  scope :admin, -> { where(id: UserRole.id_for(:admin)) }
  scope :finance_manager, -> { where(id: UserRole.id_for(:finance_manager)) }
  scope :manager, -> { where(id: UserRole.id_for(:manager)) }
  scope :employee, -> { where(id: UserRole.id_for(:employee)) }
  scope :auditor, -> { where(id: UserRole.id_for(:auditor)) }

  VALUES = {admin: 1, finance_manager: 2, manager: 3, employee: 4, auditor: 5}

  self.class.instance_eval do
    VALUES.each do |key, value|
      define_method "#{key}_id" do
        value
      end
    end
  end

  def self.id_for(role)
    role == :finance_manager if role == :finance
    VALUES[role]
  end

  def self.name_for(role_id)
    VALUES.key(role_id)
  end

end
