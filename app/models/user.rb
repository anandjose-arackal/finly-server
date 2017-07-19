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
#  first_name             :string(255)
#  last_name              :string(255)
#  mobile_only_invite     :boolean          default(FALSE)
#  mothers_maiden_name    :string(255)
#  verified               :boolean          default(FALSE)
#  otp_request_type_id    :integer
#  default_password       :boolean          default(FALSE)
#  point_of_contact       :boolean          default(FALSE)
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
  belongs_to :otp_request_type

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
  has_one :auto_submit_config, as: :submitable, dependent: :destroy
  has_one :enforce_policy, as: :enforceable, dependent: :destroy
  has_one :auto_reload_config, as: :reloadable, dependent: :destroy
  has_one :itz_cash_dmt_sender
  has_one :user_panel_subscription

  has_many :authentications
  has_many :cards, dependent: :destroy
  has_many :card_transactions, dependent: :destroy
  has_many :money_requests
  has_many :controlling_money_requests, class_name: 'MoneyRequest', foreign_key: :controlling_user_id
  has_many :money_request_tracks, class_name: 'MoneyRequestTrack', foreign_key: :action_user_id
  has_many :interacted_money_requests, -> { distinct }, source: :money_request, through: :money_request_tracks
  has_many :manager_money_request_tracks, -> { manager_role }, class_name: 'MoneyRequestTrack', foreign_key: :modified_user_id
  has_many :manager_money_requests, -> { distinct }, source: :money_request, through: :manager_money_request_tracks
  has_many :finance_money_request_tracks, -> { finance_manager_role }, class_name: 'MoneyRequestTrack', foreign_key: :modified_user_id
  has_many :finance_money_requests, -> { distinct }, source: :money_request, through: :finance_money_request_tracks
  has_many :notifications, dependent: :destroy
  has_many :notifier_type_configurations
  has_many :user_balance_histories
  has_many :feedbacks
  has_many :payment_orders, foreign_key: :initiating_user_id
  has_many :user_group_item_mappings
  has_many :user_group_items, through: :user_group_item_mappings
  has_many :expense_data_extracts, as: :sourcable
  has_many :receipt_email_parse_failures
  has_many :user_login_tracks
  has_many :login_agreement_mappings
  has_many :agreements, through: :login_agreement_mappings
  has_many :card_assign_requests, foreign_key: :card_owner_id
  has_many :card_upgrade_requests, foreign_key: :card_owner_id

  has_one :individual_kyc
  has_one :itz_cash_dmt_sender

  # has_one :feature_access, as: :accessible

  accepts_nested_attributes_for :role_mapping
  accepts_nested_attributes_for :team_mapping
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :cards
  accepts_nested_attributes_for :itz_cash_dmt_sender
  accepts_nested_attributes_for :user_panel_subscription
  # accepts_nested_attributes_for :feature_access

  delegate :employee_id, :payroll_id, :city, :address_1, :address_2, :date_of_birth, :pin_code, :gender_name, :state_id, :state_name, to: :profile
  delegate :company_name, to: :company

  has_paper_trail

  validates :company_id, presence: true
  validates :email, uniqueness: {allow_blank: true, case_sensitive: false}
  validates :first_name, presence: true, format: {allow_blank: true, with: /\A[a-zA-Z0-9 ]+\Z/}, length: {maximum: 30}
  validates :last_name, presence: true, format: {allow_blank: true, with: /\A[a-zA-Z0-9 ]+\Z/}, length: {maximum: 30}
  validates :mothers_maiden_name, presence: true, format: {allow_blank: true, with: /\A[a-zA-Z0-9 ]+\Z/}, length: {maximum: 30}
  validates :mobile_number, presence: true, format: {allow_blank: true, with: Constants::VALID_MOBILE_NUMBER}, uniqueness: true
  validates :user_panel_subscription, presence: true

  scope :with_id, ->(user_id) { where id: user_id }
  scope :with_company_id, ->(company_id) { where company_id: company_id }
  scope :without_id, ->(user_id) { where.not id: user_id }
  scope :filter_name, -> (name) do
    where 'first_name like ? or last_name like ? or concat(first_name, ' ', last_name) like ? or concat(first_name, ' ', last_name) like ?',
          "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%"
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

  # Users having cards assigned with the given program
  scope :with_cards_having_card_program, ->(id) do
    user_ids = pluck(:id)
    ids = Card.with_user(user_ids).with_card_program(id).pluck(:user_id)
    self.with_id(ids)
  end

  # Users having finly money balance greater than 0
  scope :having_wallet_balance, ->(required = true) do
    if required
      user_ids = pluck(:id)
      ids = UserWallet.with_user(user_ids).having_balance_value.pluck(:user_id)
      self.with_id(ids)
    else
      self
    end
  end

  # Users having finly money balance greater than 0
  scope :having_cash_on_hand_balance, -> (required = true) do
    if required
      user_ids = pluck(:id)
      ids = BalanceSheet.with_user(user_ids).having_cash_in_hand_balance_value.pluck(:user_id)
      self.with_id(ids)
    else
      self
    end
  end

  scope :filter_reports_awaiting_settlement, ->(required = true) do
    if required
      user_ids = pluck(:id)
      ids = Report.all.with_user(user_ids).approved.pluck(:user_id)
      self.with_id(ids)
    else
      self
    end
  end

  scope :filter_pending_money_requests, -> (required = true) do
    if required
      user_ids = pluck(:id)
      ids = MoneyRequest.all.with_user(user_ids).approved.pluck(:user_id)
      self.with_id(ids)
    else
      self
    end
  end

  # scopes for filters
  # scope :filter_search, -> (term) { where("first_name like ? OR last_name like ? OR email like ?", "%#{term}%", "%#{term}%","%#{term}%","%#{term}%") }
  scope :filter_search, ->(term) do
    where "first_name like ? or last_name like ? or concat(first_name, ' ', last_name) like ? or concat(first_name, ' ', last_name) like ? or email like ? or mobile_number like ?",
          "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%"
  end

  scope :filter_state, -> (state) do
    if state.blank?
      state = []
    end

    unless state.is_a?(Array)
      state = [state]
    end

    active = (state.include?('1') or state.include?(1))
    pending = (state.include?('2') or state.include?(2))
    inactive = (state.include?('3') or state.include?(3))

    query = ''
    if active
      query += ' OR ' unless query.blank?
      query += "`users`.`active` = 1 AND `users`.`invitation_token` IS NULL AND (NOT ((`users`.`first_name` = '' OR `users`.`first_name` IS NULL))) AND (`users`.`mobile_only_invite` != 1)"
      # query += '(active = 1 AND invitation_token IS NULL AND (NOT ((first_name = ' ' OR first_name IS NULL))) AND (mobile_only_invite != 1)'
    end
    if pending
      query += ' OR ' unless query.blank?
      query += "(first_name = '' OR invitation_token IS NOT NULL OR mobile_only_invite = 1)"
      # query += 'first_name = ' ' OR invitation_token IS NOT NULL OR mobile_only_invite = 1'
    end
    if inactive
      query += ' OR ' unless query.blank?
      query += "`users`.`active` = 0 AND (NOT ((`users`.`first_name` = '' OR `users`.`first_name` IS NULL))) AND (`users`.`mobile_only_invite` != 1)"
      # query += "active = 0 AND (NOT ((first_name = '' OR first_name IS NULL))) AND (mobile_only_invite != 1)"
    end
    if query.present?
      where(query)
    else
      self
    end
  end

  scope :filter_role, -> (role) do

    if role.blank?
      role = []
    end

    unless role.is_a?(Array)
      role = [role]
    end

    # "99" is for filtering only employees who are not admins / managers / finance managers
    include_employee_only = (role.include?(99) or role.include?('99'))

    users_with_mapping = joins(:role_mapping).select('users.*')

    if include_employee_only

      if role.size == 1
        # If requested for employee only, then select users who are not managers, admins and finance managers
        ids = users_with_mapping.where('user_role_id IN (?)', [UserRole.id_for(:admin), UserRole.id_for(:manager), UserRole.id_for(:finance_manager)]).pluck(:id)
        where.not id: ids
      else
        # If requested in combination with employees only and (admin or manager or finance manager)
        ids = users_with_mapping.where('user_role_id IN (?)', [UserRole.id_for(:admin), UserRole.id_for(:manager), UserRole.id_for(:finance_manager)]).pluck(:id)
        users_with_mapping.where('user_role_id IN (?) OR users.id NOT IN (?)', role, ids)
      end

    else

      # Regular role based search
      users_with_mapping.where('user_role_id IN (?)', role)

    end

  end

  scope :filter_company_id, -> (company_id) { where company_id: company_id }
  scope :company_id, -> (company_id) { where company_id: company_id }

  scope :created_between, -> (date_from, date_to) {
    unless date_from.blank? && date_to.blank?
      type_val = :created_at
      date_from = "1990-01-01" if date_from.blank?
      date_to = DateUtils.local_date if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date if date_to.present?
      users = arel_table
      where(users[type_val].gteq(date_from).and(users[type_val].lteq(date_to)))
    end
  }

  scope :filter_date_from, -> (start_date) {
    start_date = start_date.to_date
    where('created_at >= ?', start_date)
  }

  scope :filter_date_to, -> (end_date) {
    end_date = end_date.to_date + 1
    where('created_at <= ?', end_date)
  }

  scope :signed_up, -> { where(invitation_token: nil).where.not(first_name: [nil, ""]).where.not(mobile_only_invite: true) }
  scope :pending, -> { where('first_name = ? OR invitation_token IS NOT ? OR mobile_only_invite = ?', "", nil, true) }
  scope :only_employees, -> { where('user_role_mappings.user_role_id = ?', UserRole.employee_id).uniq }
  scope :sort_by_name, -> { order(first_name: :asc, last_name: :asc) }
  scope :with_balance_sheet, -> { includes(:balance_sheet => [:cash_in_hand, :approved_reports_total]) }

  scope :filter_disburse, -> (enabled) {
    if enabled == '1' || enabled == 1
      joins(:user_panel_subscription).select('users.*').where('disburse = ?', true)
    else
      joins(:user_panel_subscription).select('users.*').where('disburse = ? or disburse = ?', false, nil)
    end
  }

  scope :filter_expense_management, -> (enabled) {
    if enabled == '1' || enabled == 1
      joins(:user_panel_subscription).select('users.*').where('expense_management = ?', true)
    else
      joins(:user_panel_subscription).select('users.*').where('expense_management = ? or expense_management = ?', false, nil)
    end
  }

  scope :point_of_contact, -> {
    where point_of_contact: true
  }

  scope :filter_card_number, -> (term) {
    joins(:cards).select('users.*').where('proxy like ?', "%#{term}%")
  }

  after_create do
    # self.build_profile.save if self.profile.blank?
    default_policy_id = self.company.default_policy.id
    self.team_mapping.build(default: true, policy_id: default_policy_id).save if self.team_mapping.count == 0
    self.policy_user_mappings.build(policy_id: default_policy_id).save
    self.build_balance_sheet.save if self.balance_sheet.blank?
    self.build_wallet(balance_attributes: {value: 0, currency_id: Currency.first.id}).save if self.wallet.blank?
    self.build_auto_submit_config(period_id: Period.id_for(:week), enabled: false, limit_to_card_expenses: true).save
    self.build_enforce_policy(enabled: false).save
    self.build_auto_reload_config(enabled: false).save
    self.build_individual_kyc(company_id: self.company_id, kyc_status_id: KycStatus.id_for(:incomplete), admin_review_workflow: AdminReviewWorkflow.workflow_for(:kyc_update)).save if self.individual_kyc.blank?
  end

  def payments
    Payment.involving_user(self.id)
  end

  def name
    return nil if first_name.blank? and last_name.blank?
    name = first_name
    "#{name} #{last_name}"
  end

  alias_method :requested_by_user_name, :name

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

  # todo - temporarily disabling policy admin screen for the admin? role
  def admin?
    company_admin?
  end

  def finance_manager?
    mapping = self.role_mapping
    mapping.finance_manager.present?
  end

  def manager?
    mapping = self.role_mapping
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

  def first_time_login?
    !self.default_password
  end

  # Checks the cash in hand on the date given and current date and responds with whichever is lower
  def cash_in_hand(date = nil)
    date_obj = date
    unless date.kind_of?(Date)
      date_obj = date.to_date rescue nil
    end
    cash = self.balance_sheet.cash_in_hand
    return cash if date_obj.blank? or date_obj == DateUtils.local_date
    history = self.user_balance_histories.find_by(date: date_obj)
    if history.blank?
      return Amount.new(value: 0, currency_id: 1)
    else
      cash_on_hand = history.cash_on_hand_balance
      return cash_on_hand
    end
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

  # overriding devise's default method so that it compares against both email and phone number to authenticate
  def self.find_for_database_authentication(conditions={})
    return nil if conditions.blank? or conditions[:username].blank?
    username = conditions[:username].delete(' ')
    find_by(mobile_number: username) || find_by(email: username)
  end

  def manager_activateable?
    self.invitation_token.blank? and self.email.blank? and self.mobile_only_invite
  end

  def otp_confirm
    self.update_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
  end

  def enforce_policy_enabled?
    self.enforce_policy.enabled
  end

  def superadmin?
    if Constants::SUPERADMIN_ACCOUNTS.include?(self.email)
      true
    else
      false
    end
  end

  def distance_expense_enabled?
    if self.company.distance_expense_enabled?
      return true
    end
    policies = self.policies
    policies.each do |policy|
      if policy.distance_expense_enabled?
        return true
      end
    end
    # if none of the above conditions are satisfied
    false
  end

  def time_expense_enabled?
    if self.company.time_expense_enabled?
      return true
    end
    policies = self.policies
    policies.each do |policy|
      if policy.time_expense_enabled?
        return true
      end
    end
    # if none of the above conditions are satisfied
    false
  end

  # returns the list of per diems that the user has access to
  def per_diems_list
    per_diems = self.company.per_diems.active
    policies = self.policies
    policies.each do |policy|
      per_diems += policy.per_diems.active
    end
    per_diems
  end

  def per_diem_expense_enabled?
    if self.company.per_diem_expense_enabled?
      return true
    end
    policies = self.policies
    policies.each do |policy|
      if policy.per_diem_expense_enabled?
        return true
      end
    end
    # if none of the above conditions are satisfied
    false
  end

  # returns the sate of the particular user - active, inactive or pending
  def user_state
    if self.active && self.invitation_token.nil? && !self.first_name.blank? && !self.mobile_only_invite
      return 1
    elsif self.mobile_only_invite || self.first_name.nil? || !self.invitation_token.blank?
      return 2
    elsif !self.active && !self.first_name.blank? && !self.mobile_only_invite
      return 3
    end
  end

  def expense_card_assignable?
    if self.cards.expense_cards.present?
      return false
    end
    true
  end

  def finly_admin?
    jouska_id = Company.find_by(name: "Jouska").id rescue nil
    unless Rails.env.production?
      if ['king@demo.com', 'king@finlytest.io'].include?(self.email)
        return true
      end
    end

    if self.company_id == jouska_id
      return true
    else
      return false
    end
  end

  private

# def valid_role
#   if self.role_mapping.count == 0
#     errors.add(:user, "must be assigned a role")
#   end
# end

end
