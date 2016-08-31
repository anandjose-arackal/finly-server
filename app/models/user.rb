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
#  mobile_number          :string(255)
#  active                 :boolean          default(TRUE), not null
#  invitation_token       :string(255)
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string(255)
#  invitations_count      :integer          default(0)
#
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :lockable

  devise :database_authenticatable, :validatable, password_length: 8..128

  attr_accessor :view

  belongs_to :company
  has_one :profile, class_name: 'UserProfile', dependent: :destroy
  has_many :role_mapping, class_name: 'UserRoleMapping', dependent: :destroy
  has_many :user_roles, through: :role_mapping, dependent: :destroy
  has_many :team_mapping, class_name: 'UserManagerMapping', dependent: :destroy
  has_many :tags, class_name: 'UserTag', dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :policy_user_mappings, dependent: :destroy
  has_many :policies, through: :policy_user_mappings, dependent: :destroy
  has_many :admin_policy_user_mappings, -> { admin }, class_name: 'PolicyUserMapping', foreign_key: :user_id, dependent: :destroy
  has_many :admin_policies, source: :policy, class_name: 'Policy', through: :admin_policy_user_mappings
  has_many :cards

  has_many :reports, dependent: :destroy
  has_many :controlling_reports, class_name: 'Report', foreign_key: :controlling_user_id
  has_many :report_tracks, class_name: 'ReportTrack', foreign_key: :action_user_id
  has_many :interacted_reports, -> { distinct }, source: :report, through: :report_tracks
  has_many :manager_report_tracks, -> { manager_role }, class_name: 'ReportTrack', foreign_key: :action_user_id
  has_many :manager_reports, -> { distinct }, source: :report, through: :manager_report_tracks
  has_many :finance_report_tracks, -> { finance_manager_role }, class_name: 'ReportTrack', foreign_key: :action_user_id
  has_many :finance_reports, -> { distinct }, source: :report, through: :finance_report_tracks

  has_many :reviewed_reports, class_name: 'Report'
  has_one :balance_sheet, dependent: :destroy
  has_many :payments, foreign_key: 'receiving_user_id', class_name: 'Payment', dependent: :destroy
  has_many :initiating_payments, foreign_key: 'initiating_user_id', class_name: 'Payment', dependent: :destroy
  has_many :invitations, :class_name => 'User', :as => :invited_by

  has_many :cards
  has_many :card_load_requests
  has_many :controlling_card_load_requests, class_name: 'CardLoadRequest', foreign_key: :controlling_user_id
  has_many :card_transactions

  has_many :event_configurations

  accepts_nested_attributes_for :role_mapping
  accepts_nested_attributes_for :team_mapping
  accepts_nested_attributes_for :profile

  delegate :employee_id, to: :profile
  delegate :payroll_id, to: :profile
  delegate :company_name, to: :company

  has_paper_trail

  validates :company_id, presence: true
  validates :email, presence: true, format: Constants::VALID_EMAIL_FORMAT, uniqueness: {case_sensitive: false}
  validates :name, presence: true

  # validate :valid_role

  scope :with_id, ->(user_id) { where id: user_id }
  scope :without_id, ->(user_id) { where.not id: user_id }
  scope :filter_name, -> (name) { where("name like ?", "%#{name}%") }
  scope :filter_email, -> (email) { where("email like ?", "%#{email}%") }
  scope :with_roles, -> { joins :role_mapping }
  scope :only_managers, -> { where "user_role_mappings.user_role_id = ?", UserRole.manager_id }
  scope :only_finance_managers, -> { where "user_role_mappings.user_role_id = ?", UserRole.finance_manager_id }
  scope :only_admins, -> { where "user_role_mappings.user_role_id = ?", UserRole.admin_id }
  scope :sort_by_name, -> { order(name: :asc) }
  scope :active, -> { where active: true }

  # scopes for filters
  scope :filter_search, -> (term) {where("name like ? OR email like ?", "%#{term}%", "%#{term}%")}
  scope :filter_state, -> (state) {
    case(state)
      when 1
        where(active: true)
      when 2
        where(active: false)
      when 3
        where.not(invitation_token: nil)
    end
  }

  scope :filter_role, -> (role) {
    joins(:role_mapping).select("users.*").where('user_role_id = ?', role)
  }

  scope :signed_up, -> {where invitation_token: nil}
  scope :pending, -> {where.not(invitation_token: nil)}
  scope :only_employees, -> { where("user_role_mappings.user_role_id = ?", UserRole.employee_id).uniq }
  scope :sort_by_name, -> { order(name: :asc) }
  scope :with_balance_sheet, -> { includes(:balance_sheet => [:cash_in_hand, :pending_reimbursement]) }

  after_create do
    self.build_profile.save if self.profile.blank?
    self.team_mapping.build(default: true).save if self.team_mapping.count == 0
    self.build_balance_sheet.save if self.balance_sheet.blank?
  end

  def name_shortened
    abbr = name[0]
    parts = name.split
    if parts.size >= 2
      abbr += parts.second[0]
    end
    abbr.upcase
  end

  def roles
    self.user_roles
  end

  def company_admin?
    role_mapping.admin.present?
  end

  # If policy is passed checks if the user is the admin of the given policy
  # Else if any policy exists for which the user is an admin
  def policy_admin?(policy = nil)
    if policy.blank?
      return admin_policies.count > 0
    end
    policy_id = policy
    if policy.is_a?(Policy)
      policy_id = policy.id
    end
    admin_policies.with_id(policy_id).present?
  end

  def admin?
    company_admin? or policy_admin?
  end

  def finance_manager?
    mapping = role_mapping
    mapping.finance_manager.present?
  end

  def manager?
    mapping = role_mapping
    mapping.manager.present?
  end

  def employee?
    mapping = role_mapping
    mapping.employee.present?
  end

  def auditor?
    mapping = role_mapping
    mapping.auditor.present?
  end

  def user_name
    self.name
  end

  def invite_accepted?
    self.invitation_token
  end

  alias_method :manager_name, :user_name
  alias_method :finance_manager_name, :user_name
  alias_method :approves_to_name, :user_name
  alias_method :approves_finance_to_name, :user_name


  private
  # def valid_role
  #   if self.role_mapping.count == 0
  #     errors.add(:user, "must be assigned a role")
  #   end
  # end

end
