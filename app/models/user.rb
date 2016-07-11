# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer          not null
#  name                   :string(255)
#  mobile_number          :integer
#  active                 :boolean          default(TRUE), not null
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  belongs_to :company
  has_one :profile, class_name: 'UserProfile', dependent: :destroy
  has_many :role_mapping, class_name: 'UserRoleMapping', dependent: :destroy
  has_many :user_roles, through: :role_mapping
  has_many :team_mapping, class_name: 'UserManagerMapping', dependent: :destroy
  has_many :tags, class_name: 'UserTag', dependent: :destroy
  has_many :expenses
  has_many :receipts
  has_many :policy_user_mappings
  has_many :policies, through: :policy_user_mappings
  accepts_nested_attributes_for :role_mapping
  accepts_nested_attributes_for :team_mapping
  accepts_nested_attributes_for :profile

  validates :company_id, presence: true
  validates :email, presence: true, format: Constants::VALID_EMAIL_FORMAT, uniqueness: {case_sensitive: false}
  validates :name, presence: true
  # validate :valid_role

  scope :by_user, ->(user_id) { find_by id: user_id }

  after_create do
    self.build_profile.save if self.profile.blank?
    self.team_mapping.build(default: true).save if self.team_mapping.count == 0
  end

  def roles
    self.user_roles
  end



  def admin?(policy=nil)
    mapping = role_mapping
    mapping = mapping.policy(policy.id) if policy.present?
    mapping.admin.present?
  end

  def finance_manager?(policy=nil)
    mapping = role_mapping
    mapping = mapping.policy(policy.id) if policy.present?
    mapping.finance_manager.present?
  end

  def manager?(policy=nil)
    mapping = role_mapping
    mapping = mapping.policy(policy.id) if policy.present?
    mapping.manager.present?
  end

  def employee?(policy=nil)
    mapping = role_mapping
    mapping = mapping.policy(policy.id) if policy.present?
    mapping.employee.present?
  end

  def auditor?(policy=nil)
    mapping = role_mapping
    mapping = mapping.policy(policy.id) if policy.present?
    mapping.auditor.present?
  end

  private
  # def valid_role
  #   if self.role_mapping.count == 0
  #     errors.add(:user, "must be assigned a role")
  #   end
  # end

end
