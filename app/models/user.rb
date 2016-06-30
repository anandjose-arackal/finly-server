class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  belongs_to :company
  has_one :profile, class_name: 'UserProfile', dependent: :destroy
  has_many :role_mapping, class_name: 'UserRoleMapping', dependent: :destroy
  has_many :user_roles,  through: :role_mapping
  has_many :team_mapping, class_name: 'UserManagerMapping', dependent: :destroy
  has_many :expenses
  accepts_nested_attributes_for :role_mapping
  accepts_nested_attributes_for :team_mapping
  accepts_nested_attributes_for :profile

  validates :company_id, presence: true
  validates :email, presence: true, format: Constants::VALID_EMAIL_FORMAT, uniqueness: {case_sensitive: false}
  validates :name, presence: true
  # validate :valid_role

  after_create do
    self.build_profile.save if self.profile.blank?
    self.team_mapping.build(default: true).save if self.team_mapping.count == 0
  end

  def roles
    self.user_roles
  end

  def admin?
    self.roles.admin.present?
  end

  def finance_manager?
    self.roles.finance_manager.present?
  end

  def manager?
    self.roles.manager.present?
  end

  def employee?
    self.roles.employee.present?
  end

  def auditor?
    self.roles.auditor.present?
  end

  private
  # def valid_role
  #   if self.role_mapping.count == 0
  #     errors.add(:user, "must be assigned a role")
  #   end
  # end

end
