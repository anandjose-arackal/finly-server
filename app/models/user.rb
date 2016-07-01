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
