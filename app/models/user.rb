# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default("")
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
#  otp                    :string(255)
#  otp_sent_at            :datetime
#  otp_verified_at        :datetime
#  otp_verified           :boolean          default(FALSE), not null
#  otp_count              :integer          default(0), not null
#  first_name             :string(255)      not null
#  maiden_name            :string(255)
#  last_name              :string(255)      not null
#  default_password       :boolean
#  mobile_only_invite     :boolean          default(FALSE)
#






class User < ActiveRecord::Base
  include OperationCallbacks
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :lockable

  devise :database_authenticatable, :validatable, password_length: 8..128

  attr_accessor :view, :invitation_note
  attr_reader :raw_invitation_token

  belongs_to :company
  has_one :profile, class_name: 'UserProfile', dependent: :destroy
  has_one :wallet, class_name: 'UserWallet', foreign_key: :user_id, dependent: :destroy

  has_many :role_mapping, class_name: 'UserRoleMapping', dependent: :destroy
  has_many :user_roles, through: :role_mapping, dependent: :destroy
  has_many :team_mapping, class_name: 'UserManagerMapping', dependent: :destroy
  has_many :tags, class_name: 'UserTag', dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :receipt_emails, dependent: :destroy
  has_many :policy_user_mappings, dependent: :destroy
  has_many :policies, through: :policy_user_mappings, dependent: :destroy
  has_many :admin_policy_user_mappings, -> { admin }, class_name: 'PolicyUserMapping', foreign_key: :user_id, dependent: :destroy
  has_many :admin_policies, source: :policy, class_name: 'Policy', through: :admin_policy_user_mappings

  has_many :reports, dependent: :destroy
  has_many :controlling_reports, class_name: 'Report', foreign_key: :controlling_user_id
  has_many :report_tracks, class_name: 'ReportTrack', foreign_key: :action_user_id
  has_many :interacted_reports, -> { distinct }, source: :report, through: :report_tracks
  has_many :manager_report_tracks, -> { manager_role }, class_name: 'ReportTrack', foreign_key: :modified_user_id
  has_many :manager_reports, -> { distinct }, source: :report, through: :manager_report_tracks
  has_many :finance_report_tracks, -> { finance_manager_role }, class_name: 'ReportTrack', foreign_key: :modified_user_id
  has_many :finance_reports, -> { distinct }, source: :report, through: :finance_report_tracks

  # has_many :reviewed_reports, class_name: 'Report'
  has_one :balance_sheet, dependent: :destroy
  has_many :initiating_payments, foreign_key: 'initiating_user_id', class_name: 'Payment', dependent: :destroy
  has_many :receiving_payments, foreign_key: 'receiving_user_id', class_name: 'Payment', dependent: :destroy
  has_many :invitations, :class_name => 'User', :as => :invited_by
  has_one :auto_submit_config, as: :submitable

  has_many :cards, dependent: :destroy
  has_many :card_transactions

  has_many :money_requests
  has_many :controlling_money_requests, class_name: 'MoneyRequest', foreign_key: :controlling_user_id
  has_many :money_request_tracks, class_name: 'MoneyRequestTrack', foreign_key: :action_user_id
  has_many :interacted_money_requests, -> { distinct }, source: :money_request, through: :money_request_tracks
  has_many :manager_money_request_tracks, -> { manager_role }, class_name: 'MoneyRequestTrack', foreign_key: :modified_user_id
  has_many :manager_money_requests, -> { distinct }, source: :money_request, through: :manager_money_request_tracks
  has_many :finance_money_request_tracks, -> { finance_manager_role }, class_name: 'MoneyRequestTrack', foreign_key: :modified_user_id
  has_many :finance_money_requests, -> { distinct }, source: :money_request, through: :finance_money_request_tracks
  has_many :notifications

  has_many :notifier_type_configurations

  accepts_nested_attributes_for :role_mapping
  accepts_nested_attributes_for :team_mapping
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :cards

  delegate :employee_id, to: :profile
  delegate :payroll_id, to: :profile
  delegate :company_name, to: :company

  has_paper_trail

  validates :company_id, presence: true
  validates :email, uniqueness: {allow_blank: true, case_sensitive: false}
  validates :name, presence: true
  validates :first_name, presence: true, format: {with: /\A[a-zA-Z0-9]+\Z/}, length: {maximum: 30}
  validates :maiden_name, length: {maximum: 30}
  validates :last_name, presence: true, format: {with: /\A[a-zA-Z0-9]+\Z/}, length: {maximum: 30}
  validates :mobile_number, presence: true, format: Constants::VALID_MOBILE_NUMBER, uniqueness: true

  validate :email_format
  # validate :valid_role

  scope :with_id, ->(user_id) { where id: user_id }
  scope :with_company_id, ->(company_id) { where company_id: company_id }
  scope :without_id, ->(user_id) { where.not id: user_id }
  scope :filter_name, -> (name) do
    where "first_name like ? or maiden_name like ? or last_name like ? or concat(first_name, ' ', last_name) like ? or concat(first_name, ' ', maiden_name, ' ', last_name) like ?",
          "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%"
  end
  scope :filter_email, -> (email) { where('email like ?', "%#{email}%") }
  scope :filter_user_id, ->(user_id) { where id: user_id }
  scope :with_roles, -> { joins :role_mapping }
  scope :only_managers, -> { with_roles.where 'user_role_mappings.user_role_id = ?', UserRole.manager_id }
  scope :only_finance_managers, -> { with_roles.where 'user_role_mappings.user_role_id = ?', UserRole.finance_manager_id }
  scope :only_admins, -> { with_roles.where 'user_role_mappings.user_role_id = ?', UserRole.admin_id }
  scope :sort_by_name, -> { order(first_name: :asc, last_name: :asc) }
  scope :active, -> { where active: true }
  scope :invited_by, ->(id) { where invited_by_id: id }

  # scopes for filters
  # scope :filter_search, -> (term) { where("first_name like ? OR maiden_name like ? OR last_name like ? OR email like ?", "%#{term}%", "%#{term}%","%#{term}%","%#{term}%") }
  scope :filter_search, ->(term) do
    where "first_name like ? or maiden_name like ? or last_name like ? or concat(first_name, ' ', last_name) like ? or concat(first_name, ' ', maiden_name, ' ', last_name) like ? or email like ?",
          "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"
  end

  scope :filter_state, -> (state) do
    case (state)
      when '1', 1
        # Active
        # Name nil is to ensure user has signed up
        where(active: true).where(invitation_token: nil).where.not(first_name: [nil, ""]).where.not(mobile_only_invite: true)
      when '2', 2
        # Pending - i.e. where name is an empty string or when there is an invitation token
        where('first_name = ? OR invitation_token IS NOT ? OR mobile_only_invite = ?',"",nil,true)
      when '3', 3
        # Inactive
        # Name nil is to ensure user has signed up
        where(active: false).where.not(first_name: [nil, ""]).where.not(mobile_only_invite: true)
    end
  end

  scope :filter_role, -> (role) {
    joins(:role_mapping).select("users.*").where('user_role_id = ?', role)
  }

  scope :signed_up, -> { where invitation_token: nil }
  scope :pending, -> { where.not(invitation_token: nil) }
  scope :only_employees, -> { where("user_role_mappings.user_role_id = ?", UserRole.employee_id).uniq }
  scope :sort_by_name, -> { order(first_name: :asc, last_name: :asc) }
  scope :with_balance_sheet, -> { includes(:balance_sheet => [:cash_in_hand, :pending_reimbursement]) }

  after_create do
    # self.build_profile.save if self.profile.blank?
    self.team_mapping.build(default: true).save if self.team_mapping.count == 0
    self.build_balance_sheet.save if self.balance_sheet.blank?
    self.build_wallet(balance_attributes: {value: 0, currency_id: Currency.first.id}).save if self.wallet.blank?
    self.build_auto_submit_config(period_id: Period.id_for(:week), enabled: false, limit_to_card_expenses: true).save
  end

  def payments
    Payment.involving_user(self.id)
  end

  def name
    return nil if first_name.blank? and maiden_name.blank? and last_name.blank?
    name = first_name
    name += " #{maiden_name}" if maiden_name.present?
    "#{name} #{last_name}"
  end

  def name_shortened
    "#{first_name[0]}#{last_name[0]}".upcase
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

  def has_role?(role_id)
    return false unless role_id.present?
    mapping = role_mapping
    mapping.role(role_id).present?
  end

  def user_name
    self.name
  end

  def invite_accepted?
    !self.invitation_token
  end

  def active_for_authentication?
    super && self.active # i.e. super && self.is_active
  end

  # overriding the requirement for emails by devise
  def email_required?
    false
  end

  def inactive_message
    "Sorry, this account has been deactivated."
  end

  # activates the user in devise
  def activate
    self.confirm
  end

  # Checks the cash in hand on the date given and current date and responds with whichever is lower
  def cash_in_hand(date = nil)
    cash = self.balance_sheet.cash_in_hand
    return cash if date.blank? or date == DateUtils.local_date
    payments = self.payments.made_after(date).with_amount
    payments_to_user = payments.transferred_cash_to_user.sum(:value)
    debt_clearance = payments.debt_clearance.sum(:value)
    settlement = payments.settlement.sum(:value)
    reports = self.reports.processed.submitted_after(date)
    report_ids = reports.pluck(:id)
    expenses = self.expenses.with_amount.with_report(report_ids).sum(:value)
    pending_reimbursement = reports.with_amount.without_payment.sum(:value)
    value = cash.value + expenses + debt_clearance + settlement - payments_to_user - pending_reimbursement
    # For checking if current cash in hand is of lower value or the prev cash in hand is of lower value
    min_value = [cash.value, value].min
    Amount.new(value: min_value, currency: cash.currency)
  end

  alias_method :manager_name, :user_name
  alias_method :finance_manager_name, :user_name
  alias_method :approves_to_name, :user_name
  alias_method :approves_finance_to_name, :user_name

  def as_json(options = {})
    json = super(options)
    json[:name] = self.name
    json
  end

  # overriding devise's default methdod so that it compares against both email and phone number to authenticate
  def self.find_for_database_authentication(conditions={})
    find_by(mobile_number: conditions[:email]) || find_by(email: conditions[:email])
  end

  def manager_activateable?
    self.invitation_token.blank? and self.email.blank? and self.mobile_only_invite
  end

  def otp_confirm
    self.update_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
  end

  private

  def email_format

  end
  # def valid_role
  #   if self.role_mapping.count == 0
  #     errors.add(:user, "must be assigned a role")
  #   end
  # end

end
