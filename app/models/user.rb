# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  email                     :string(255)      default("")
#  encrypted_password        :string(255)      default(""), not null
#  reset_password_token      :string(255)
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  sign_in_count             :integer          default(0), not null
#  current_sign_in_at        :datetime
#  last_sign_in_at           :datetime
#  current_sign_in_ip        :string(255)
#  last_sign_in_ip           :string(255)
#  confirmation_token        :string(255)
#  confirmed_at              :datetime
#  confirmation_sent_at      :datetime
#  unconfirmed_email         :string(255)
#  failed_attempts           :integer          default(0), not null
#  unlock_token              :string(255)
#  locked_at                 :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_id                :integer          not null
#  mobile_number             :string(255)
#  active                    :boolean          default(TRUE), not null
#  invitation_token          :string(255)
#  invitation_created_at     :datetime
#  invitation_sent_at        :datetime
#  invitation_accepted_at    :datetime
#  invitation_limit          :integer
#  invited_by_id             :integer
#  invited_by_type           :string(255)
#  invitations_count         :integer          default(0)
#  otp                       :string(255)
#  otp_sent_at               :datetime
#  otp_verified_at           :datetime
#  otp_verified              :boolean          default(FALSE), not null
#  otp_count                 :integer          default(0), not null
#  first_name                :string(255)
#  last_name                 :string(255)
#  mobile_only_invite        :boolean          default(FALSE)
#  mothers_maiden_name       :string(255)
#  verified                  :boolean          default(FALSE)
#  otp_request_type_id       :integer
#  default_password          :boolean          default(FALSE)
#  point_of_contact          :boolean          default(FALSE)
#  otp_attempts              :integer          default(0)
#  user_group_location_id    :integer
#  user_group_department_id  :integer
#  user_group_designation_id :integer
#  user_delegate_id          :integer
#  delegation_enabled        :boolean
#  gl_config                 :text(65535)
#  vacation_delegate_enabled :boolean
#  password_changed_at       :datetime
#  last_activity_at          :datetime
#  expired_at                :datetime
#  cost_center_id            :integer
#  department_id             :integer
#  location_id               :integer
#  default_company_id        :integer
#  finly_id                  :string(36)
#  deleted_at                :datetime
#  pending_activation        :boolean          default(FALSE)
#  erp_sync_status_id        :integer
#  erp_sync_message          :text(65535)
#  erp_sync_reference_id     :text(65535)
#  erp_sync_attempts_count   :integer          default(0)
#  erp_sync_attempted_at     :datetime
#  start_date                :date
#  end_date                  :date
#

class User < ApplicationRecord
  include OperationCallbacks
  include LiquidDroppable
  include Exposures::Model::Exposable
  include EventProducer
  include ErpSyncable
  # include SearchIndex::Concerns::Document
  include Searchkick::Api

  ACTIVE = 1
  PENDING = 2
  INACTIVE = 3

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :lockable,
         :database_authenticatable, :pwned_password

  # devise :database_authenticatable, :validatable, password_length: 8..128
  # devise :database_authenticatable
  # devise-security gem
  devise :password_expirable, :password_archivable, :expirable #, :session_limitable, :secure_validatable
  # zxcvb-js gem
  devise :zxcvbnable

  # override has_many :old_passwords from devise security to remove company_id scope
  has_many :old_passwords, -> { unscope(where: :company_id) }, class_name: 'OldPassword', as: :password_archivable, dependent: :destroy

  attr_accessor :view, :invitation_note
  attr_reader :raw_invitation_token

  serialize :gl_config

  belongs_to :company, optional: true
  belongs_to :default_company, class_name: "Company", optional: true
  belongs_to :otp_request_type, optional: true
  belongs_to :user_delegate, optional: true, class_name: "User"

  ######## Expense user specific Cost Center, Location, Department ##########
  belongs_to :cost_center, optional: true
  belongs_to :location, optional: true, class_name: "BranchLocation"
  belongs_to :department, optional: true

  has_one :profile, class_name: 'UserProfile'
  has_one :wallet, class_name: 'UserWallet', foreign_key: :user_id
  has_one :bank_wallet, class_name: 'VendorPaymentWallet', foreign_key: :user_id, dependent: :destroy
  has_many :role_mapping, class_name: 'UserRoleMapping', dependent: :destroy
  has_many :user_roles, through: :role_mapping, dependent: :destroy
  has_many :team_mapping, class_name: 'UserManagerMapping', dependent: :destroy
  has_many :tags, class_name: 'UserTag', dependent: :destroy
  has_many :expenses, inverse_of: :user, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :receipt_emails, dependent: :destroy
  has_many :policy_user_mappings, dependent: :destroy
  has_many :policies, -> { where(:'policy_user_mappings.deleted_at' => nil) }, through: :policy_user_mappings, dependent: :destroy
  has_many :admin_policy_user_mappings, -> { admin }, class_name: 'PolicyUserMapping', foreign_key: :user_id, dependent: :destroy
  has_many :admin_policies, source: :policy, class_name: 'Policy', through: :admin_policy_user_mappings
  has_many :reports, inverse_of: :user, dependent: :destroy
  has_many :controlling_reports, class_name: 'Report', foreign_key: :controlling_user_id
  has_many :report_tracks, class_name: 'ReportTrack', foreign_key: :action_user_id
  has_many :interacted_reports, -> { distinct }, source: :report, through: :report_tracks
  has_many :manager_report_tracks, -> { manager_role }, class_name: 'ReportTrack', foreign_key: :modified_user_id
  has_many :manager_reports, -> { distinct }, source: :report, through: :manager_report_tracks
  has_many :finance_report_tracks, -> { finance_manager_role }, class_name: 'ReportTrack', foreign_key: :modified_user_id
  has_many :finance_reports, -> { distinct }, source: :report, through: :finance_report_tracks
  has_many :policy_user_roles
  # Fixme: Replace this with policies as policies should ideally be deprecated
  has_many :policy_user_roles_policies, -> { where(:'policy_user_roles.deleted_at' => nil) }, through: :policy_user_roles
  # has_many :reviewed_reports, class_name: 'Report'
  has_one :balance_sheet, dependent: :destroy
  has_many :initiating_payments, foreign_key: 'initiating_user_id', class_name: 'Payment'
  has_many :receiving_payments, foreign_key: 'receiving_user_id', class_name: 'Payment'
  has_many :invitations, :class_name => 'User', :as => :invited_by
  has_one :auto_submit_config, as: :submitable, dependent: :destroy
  has_one :enforce_policy, as: :enforceable, dependent: :destroy
  has_one :auto_reload_config, as: :reloadable, dependent: :destroy
  has_one :itz_cash_dmt_sender
  has_one :user_panel_subscription
  has_one :cash_on_hand, dependent: :destroy
  has_one :quickbooks_user, class_name: "QuickbooksFinlyIntegrationsUser"
  has_one :permission, class_name: "UserPermission"

  has_many :admin_summary_mail_configs, dependent: :destroy
  has_many :manager_summary_mail_configs, dependent: :destroy
  has_many :payment_receivables, foreign_key: :initiating_user_id
  has_many :user_pockets

  has_many :analytics_dashboards, foreign_key: :created_by_id

  has_many :export_jobs, foreign_key: :created_by_id
  has_many :import_jobs, foreign_key: :created_by_id

  # adding association to drop down items
  has_many :user_drop_down_item_mappings


  has_many :bank_accounts, as: :account_owner, dependent: :destroy
  has_one :default_bank_account, -> {where default_account: true}, class_name: "BankAccount", as: :account_owner
  has_many :authentications
  has_many :cards, dependent: :destroy
  has_many :payroll_cards, -> { where(card_program_id: CardProgram.id_for(:payroll)) }, class_name: 'Card'
  has_many :reimbursement_cards, -> { where(card_program_id: CardProgram.id_for(:reimbursement)) }, class_name: 'Card'
  has_many :reimbursement_payroll_cards, -> { where(card_program_id: [CardProgram.id_for(:reimbursement), CardProgram.id_for(:payroll)]) }, class_name: 'Card'
  has_many :meal_cards, -> { where(card_program_id: CardProgram.id_for(:meal)) }, class_name: 'Card'
  has_many :medical_cards, -> { where(card_program_id: CardProgram.id_for(:medical)) }, class_name: 'Card'
  has_many :expense_cards, -> { where(card_program_id: CardProgram.id_for(:expense)) }, class_name: 'Card'
  has_many :card_transactions, dependent: :destroy
  has_many :money_requests, inverse_of: :user

  has_many :booking_attachments
  has_many :file_managers


  has_many :controlling_money_requests, class_name: 'MoneyRequest', foreign_key: :controlling_user_id
  has_many :money_request_tracks, class_name: 'MoneyRequestTrack', foreign_key: :action_user_id
  has_many :interacted_money_requests, -> { distinct }, source: :money_request, through: :money_request_tracks
  has_many :manager_money_request_tracks, -> { manager_role }, class_name: 'MoneyRequestTrack', foreign_key: :modified_user_id
  has_many :manager_money_requests, -> { distinct }, source: :money_request, through: :manager_money_request_tracks
  has_many :finance_money_request_tracks, -> { finance_manager_role }, class_name: 'MoneyRequestTrack', foreign_key: :modified_user_id
  has_many :finance_money_requests, -> { distinct }, source: :money_request, through: :finance_money_request_tracks
  has_many :notifications, dependent: :destroy
  has_many :notifier_type_configurations
  has_many :user_balance_histories, dependent: :destroy
  has_many :feedbacks
  has_many :payment_orders, foreign_key: :initiating_user_id
  has_many :user_group_item_mappings
  has_many :user_group_items, through: :user_group_item_mappings
  has_many :expense_data_extracts, as: :sourcable
  has_many :receipt_email_parse_failures
  has_many :user_login_tracks, dependent: :destroy
  has_many :user_auth_failures
  has_many :login_agreement_mappings
  has_many :agreements, through: :login_agreement_mappings
  has_many :card_assign_requests, foreign_key: :card_owner_id
  has_many :card_upgrade_requests, foreign_key: :card_owner_id
  has_many :virtual_bank_accounts, foreign_key: :initiating_user_id

  has_many :web_hooks, foreign_key: :created_by_user_id

  # adding associations for the user manager mapping for payment requests
  has_many :bank_payment_requests, foreign_key: :owner_id
  has_many :bank_payment_request_trails, class_name: "BankPaymentRequestTrail", foreign_key: :action_user_id
  has_many :controlling_payment_requests, class_name: "BankPaymentRequest", foreign_key: :controlling_user_id
  has_many :interacted_payment_requests, -> { distinct }, source: :bank_payment_request, through: :bank_payment_request_trails
  has_many :manager_payment_request_trails, -> { manager_role }, class_name: 'BankPaymentRequestTrail', foreign_key: :modified_user_id
  has_many :manager_payment_requests, -> { distinct }, source: :bank_payment_request, through: :manager_payment_request_trails
  has_many :finance_payment_request_trails, -> { finance_manager_role }, class_name: 'BankPaymentRequestTrail', foreign_key: :modified_user_id
  has_many :finance_payment_requests, -> { distinct }, source: :bank_payment_request, through: :finance_payment_request_trails

  # adding associations for the user manager mapping of travel requests
  has_many :travel_requests
  has_many :travel_request_trails, class_name: "TravelRequestTrail", foreign_key: :action_user_id
  has_many :controlling_travel_requests, class_name: "TravelRequest", foreign_key: :controlling_user_id
  has_many :interacted_travel_requests, -> { distinct }, source: :travel_requests, through: :travel_request_trails
  has_many :manager_travel_request_trails, -> { manager_role }, class_name: 'TravelRequestTrail', foreign_key: :modified_user_id
  has_many :manager_travel_requests, -> { distinct }, source: :travel_request, through: :manager_travel_request_trails
  has_many :travel_manager_travel_request_trails, -> { travel_manager_role }, class_name: 'TravelRequestTrail', foreign_key: :modified_user_id
  has_many :travel_manager_travel_requests, -> { distinct }, source: :travel_request, through: :travel_manager_travel_request_trails

  # Trips - New
  has_many :trips, foreign_key: :created_by_id

  # Outward invoice
  has_many :outward_invoices
  has_many :outward_invoice_attachments
  has_many :resource_templates
  has_many :purchase_order_templates, -> { filter_resource_type(:purchase_orders) }, class_name: 'ResourceTemplate', foreign_key: :user_id
  has_many :invoice_templates, -> { filter_resource_type(:invoices) }, class_name: 'ResourceTemplate', foreign_key: :user_id

  # Inward Invoices
  has_many :inward_invoices, class_name: "Invoice", foreign_key: :created_by_user_id
  has_many :credit_notes

  has_many :user_department_mappings
  has_many :departments, through: :user_department_mappings

  # adding a many to many association for user and his/her delegates
  has_many :user_delegate_mappings
  has_many :delegated_for_users, class_name: "User", through: :user_delegate_mappings, source: :delegate_for_user

  # P2P Documents
  has_many :purchase_orders
  has_many :purchase_requests, foreign_key: :creator_id

  # Utility Bills
  has_many :bbps_subscriptions, class_name: 'BbpsBillerSubscription'
  has_many :bbps_bills

  # Budgets

  # many-to-many mapping between user and budget
  has_many :budget_criteria_mappings, as: :budgetable
  has_many :budgets, through: :budget_criteria_mappings

  has_many :owned_budgets, class_name: 'Budget'

  has_many :procurements
  has_many :level_reviewer_mappings
  has_many :level_user_reviewer_mappings
  alias_method :lurms, :level_user_reviewer_mappings
  has_many :procurement_attachments
  has_many :attachments, foreign_key: :creator_id

  has_one :individual_kyc, dependent: :destroy
  has_one :itz_cash_dmt_sender
  has_one :user_permission, dependent: :destroy

  has_many :user_sessions
  has_many :user_devices, foreign_key: :user_finly_id, primary_key: :finly_id
  has_many :user_ips, foreign_key: :user_finly_id, primary_key: :finly_id
  has_many :user_agent_clients, foreign_key: :user_finly_id, primary_key: :finly_id

  has_many :user_branch_location_mappings
  has_many :branch_locations, through: :user_branch_location_mappings

  has_many :rate_contracts, foreign_key: :creator_id

  has_many :vendors, class_name: "YesBankVendor", foreign_key: :created_by_id

  has_many :payment_agreements, foreign_key: :creator_id

  has_many :document_message_receipts
  has_many :document_messages

  has_many :users_with_group_mapping
  has_many :group_companies, through: :users_with_group_mapping, foreign_key: :company_id
  has_many :group_users, through: :users_with_group_mapping, foreign_key: :user_id
  # has_one :feature_access, as: :accessible

  has_many :map_location_user_queries
  has_many :index_view_segments

  has_many :common_import_requests

  accepts_nested_attributes_for :role_mapping
  accepts_nested_attributes_for :team_mapping
  accepts_nested_attributes_for :profile
  accepts_nested_attributes_for :cards
  accepts_nested_attributes_for :itz_cash_dmt_sender
  accepts_nested_attributes_for :user_panel_subscription
  accepts_nested_attributes_for :quickbooks_user
  accepts_nested_attributes_for :enforce_policy

  delegate :payroll_id, :city, :address_1, :address_2, :date_of_birth, :pin_code, :gender_name, :state_id, :state_name, to: :profile
  delegate :employee_id, to: :profile, allow_nil: true
  delegate :company_name, to: :company

  ############# Devise validateable validations ############
  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of :password, within: (8..128), allow_blank: true
  ################ End of Devise validateable ##############

  validates :company_id, presence: true
  validates :email, uniqueness: {allow_blank: true, case_sensitive: false, scope: :company_id}, format: {allow_blank: true, with: Constants::VALID_EMAIL_FORMAT}
  validates :first_name, presence: true, format: {allow_blank: true, with: /\A[a-zA-Z0-9\. ']+\Z/}, length: {maximum: 30}
  validates :last_name, presence: true, format: {allow_blank: true, with: /\A[a-zA-Z0-9\. ']+\Z/}, length: {maximum: 30}
  validates :mobile_number, presence: true, format: {allow_blank: true, with: Constants::VALID_MOBILE_NUMBER}, uniqueness: {case_sensitive: false, scope: :company_id}
  validates :user_panel_subscription, presence: true
  validate :password_complexity

  scope :with_id, ->(user_id) { where id: user_id }
  scope :with_ids, -> (user_ids) { where id: user_ids }
  scope :with_id_or_email_or_mobile_number, -> (string) {
    ids = where('users.id = ? OR users.email = ? OR users.mobile_number = ?', string, string, string).pluck('users.id')
    where id: ids
  }
  scope :with_company_id, ->(company_id) { where company_id: company_id }
  scope :without_company_id, -> (company_id) { where.not(company_id: company_id) }
  scope :without_id, ->(user_id) { where.not id: user_id }
  scope :filter_name, -> (name) do
    where 'first_name like ? or last_name like ? or concat(first_name, ' ', last_name) like ? or concat(first_name, ' ', last_name) like ?',
          "%#{name}%", "%#{name}%", "%#{name}%", "%#{name}%"
  end
  scope :filter_email, -> (email) { where('email like ?', "%#{email}%") }
  scope :filter_user_id, ->(user_id) { where id: user_id }
  scope :with_roles, -> { joins :role_mapping }
  scope :only_managers, -> { with_roles.where('user_role_mappings.user_role_id = ?', UserRole.manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:expense_management)) }
  # scope :only_vendor_payment_reviewers, -> { with_roles.where('user_role_mappings.user_role_id = ?', UserRole.manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:vendor_payments))}
  scope :only_vendor_payment_reviewers, -> { with_roles.joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('user_role_mappings.user_role_id = ?', UserRole.manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:vendor_payments)) }

  scope :filter_vendor_payments_reviewers, -> (flag) { # passed argument is only for has scope, no effect here
  with_roles.joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('user_role_mappings.user_role_id = ?', UserRole.manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:vendor_payments)) }

  # Use only for has_scope filter, scope to policy_user_roles
  scope :policy_id, -> (policy_id) {
    joins(:policy_user_roles).where('policy_user_roles.policy_id = ?', policy_id)
  }

  scope :reviewer_type, -> (type) {
    case type
    when 'PurchaseOrderProvider', :PurchaseOrderProvider
      joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).joins(:policy_user_roles).where("policy_user_roles.user_role_id = ?", UserRole.id_for(:purchase_order_reviewer)).distinct
      # when 'InvoiceProvider', :InvoiceProvider
      #   joins(:user_panel_subscription).joins(:policy_user_roles).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:invoice_reviewer)).distinct
    when 'BankPaymentRequestProvider', :BankPaymentRequestProvider
      joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).joins(:policy_user_roles).where("policy_user_roles.user_role_id = ?", UserRole.id_for(:bank_payment_request_reviewer)).distinct
    when 'YesBankVendorProvider', :YesBankVendorProvider
      joins(:user_panel_subscription).joins(:policy_user_roles).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:vendor_reviewer)).distinct
    when 'PurchaseRequestProvider', :PurchaseRequestProvider
      joins(:user_panel_subscription).joins(:policy_user_roles).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:purchase_request_reviewer)).distinct
    when 'PaymentAgreementProvider', :PaymentAgreementProvider
      joins(:user_panel_subscription).joins(:policy_user_roles).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:payment_agreement_reviewer)).distinct
    when 'PoInvoiceProvider', :PoInvoiceProvider
      joins(:user_panel_subscription).joins(:policy_user_roles).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:po_invoice_reviewer)).distinct
    when 'NonPoInvoiceProvider', :NonPoInvoiceProvider
      joins(:user_panel_subscription).joins(:policy_user_roles).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:non_po_invoice_reviewer)).distinct
    when 'AgreementInvoiceProvider', :AgreementInvoiceProvider
      joins(:user_panel_subscription).joins(:policy_user_roles).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('policy_user_roles.user_role_id = ?', UserRole.id_for(:agreement_invoice_reviewer)).distinct
    end
  }

  scope :filter_em_reviewers, -> (flag) {
    with_roles.joins(:user_panel_subscription).where('user_panel_subscriptions.expense_management = ?', true).where('user_role_mappings.user_role_id = ?', UserRole.manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:expense_management))
  }
  scope :only_finance_managers, -> { with_roles.where('user_role_mappings.user_role_id = ?', UserRole.finance_manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:expense_management)) }
  scope :only_vendor_payment_creditors, -> { with_roles.joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('user_role_mappings.user_role_id = ?', UserRole.finance_manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:vendor_payments)) }
  # scope :only_vendor_payment_creditors, -> { with_roles.where('user_role_mappings.user_role_id = ?', UserRole.finance_manager_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:vendor_payments)) }
  scope :only_admins, -> { with_roles.where('user_role_mappings.user_role_id = ?', UserRole.admin_id).where('user_role_mappings.user_role_id = ?', Purpose.id_for(:expense_management)) }
  scope :only_vendor_payment_admins, -> { with_roles.joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true).where('user_role_mappings.user_role_id = ?', UserRole.admin_id).where('user_role_mappings.purpose_id = ?', Purpose.id_for(:vendor_payments)) }
  scope :only_auditors, -> { with_roles.where('user_role_mappings.user_role_id = ?', UserRole.id_for(:auditor)) }
  scope :sort_by_name, -> { order(first_name: :asc, last_name: :asc) }
  scope :active, -> { where active: true }
  scope :inactive, -> { filter_state(3) }
  scope :pending, -> { filter_state(2) }
  scope :invited_by, ->(id) { where invited_by_id: id }
  scope :with_vendor_payments_enabled, -> { joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true) }
  scope :with_expense_management_enabled, -> { joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true) }
  scope :include_all_accounts_with_balance, -> { includes(cards: [:card_balance], wallet: [:balance], cash_on_hand: [:balance], bank_wallet: [:balance]) }
  scope :include_reimbursable_accounts, -> { includes :bank_accounts, :reimbursement_cards }
  scope :with_email, ->(email) { where email: email }
  scope :with_email_or_mobile_number, -> (email, mobile_number) {
    if email.present? && mobile_number.present?
      where('email = ? OR mobile_number = ?', email, mobile_number)
    elsif email.blank?
      where('mobile_number = ?', mobile_number)
    elsif mobile_number.blank?
      where('email = ?', email)
    else
      # do nothing
    end
  }
  scope :with_subscription, -> (application) {
    ids = self.pluck(:id)
    app = nil
    case application
    when 'vp', :vp
      app = 'yes_bank_account_transfer'
    when 'em', 'ft', :em, :ft
      app = 'expense_management'
    when 'fc', :fc
      app = 'invoicing_system'
    when 'fi', :fc
      app = 'finly_insights'
    else
      # do nothing?
    end
    if app.present?
      if app == 'finly_insights'
        relevant_user_ids = ids #all users in em and vp
      else
        relevant_user_ids = UserPanelSubscription.where(user_id: ids).where(app.to_sym => true).pluck(:user_id)
      end
      where(id: relevant_user_ids)
    end
  }

  # Simplified version of the above query
  scope :with_application, -> (application = nil) {
    case application
    when 'vp', :vp
      app = 'yes_bank_account_transfer'
    when 'em', 'ft', :em, :ft
      app = 'expense_management'
    when 'fc', :fc
      app = 'invoicing_system'
    when 'fi', :fc
      app = 'finly_insights'
    else
      # do nothing?
      app = nil
    end
    if app.present? and not app == 'finly_insights'
      joins(:user_panel_subscription).where(user_panel_subscriptions: {app.to_sym => true})
    end
  }

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
    ids = self.left_outer_joins(:profile).where("users.first_name like ? or users.last_name like ? or concat(users.first_name, ' ', users.last_name) like ? or concat(users.first_name, ' ', users.last_name) like ? or users.email like ? or users.mobile_number like ? or user_profiles.employee_id like ?",
                                                "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
    ids += self.joins(:cards).where('proxy like ?', "%#{term}%")
    ids.uniq!
    self.where(id: ids)
  end

  scope :user_search, -> (term) {
    if term.present?
      ids = self.left_outer_joins(:profile).where("users.first_name like ? or users.last_name like ? or concat(users.first_name, ' ', users.last_name) like ? or concat(users.first_name, ' ', users.last_name) like ? or users.email like ? or users.mobile_number like ? or user_profiles.employee_id like ?",
                                                  "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%")
      ids.uniq!
      self.where(id: ids)
    end
  }

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
      query += "`users`.`active` = 1 AND `users`.`default_password` IS FALSE AND (NOT ((`users`.`first_name` = '' OR `users`.`first_name` IS NULL)))"
      # query += '(active = 1 AND invitation_token IS NULL AND (NOT ((first_name = ' ' OR first_name IS NULL))) AND (mobile_only_invite != 1)'
    end
    if pending
      query += ' OR ' unless query.blank?
      query += "(first_name = '' OR default_password = 1)"
      # query += 'first_name = ' ' OR invitation_token IS NOT NULL OR mobile_only_invite = 1'
    end
    if inactive
      query += ' OR ' unless query.blank?
      query += "`users`.`active` = 0 AND (NOT ((`users`.`first_name` = '' OR `users`.`first_name` IS NULL OR `users`.`default_password` = 1)))"
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

    users_with_mapping = joins(:role_mapping)

    if include_employee_only

      if role.size == 1
        # If requested for employee only, then select users who are not managers, admins and finance managers
        ids = users_with_mapping.where('user_role_mappings.user_role_id IN (?)', [UserRole.id_for(:admin), UserRole.id_for(:manager), UserRole.id_for(:finance_manager)]).pluck(:id)
        where.not id: ids
      else
        # If requested in combination with employees only and (admin or manager or finance manager)
        ids = users_with_mapping.where('user_role_mappings.user_role_id IN (?)', [UserRole.id_for(:admin), UserRole.id_for(:manager), UserRole.id_for(:finance_manager)]).pluck(:id)
        users_with_mapping.where('user_role_mappings.user_role_id IN (?) OR users.id NOT IN (?)', role, ids)
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

  scope :signed_up, -> { where(invitation_token: nil).where.not(first_name: [nil, ""]) }
  scope :pending, -> { where('first_name = ? OR default_password IS FALSE', "") }
  scope :only_employees, -> { where('user_role_mappings.user_role_id = ?', UserRole.employee_id).uniq }
  scope :sort_by_name, -> { order(first_name: :asc, last_name: :asc) }
  scope :with_balance_sheet, -> { includes(:balance_sheet => [:cash_in_hand, :approved_reports_total]) }
  scope :with_bank_accounts, -> { joins(:bank_accounts) }

  scope :filter_disburse, -> (enabled) {
    if StringUtils.to_bool(enabled)
      joins(:user_panel_subscription).where('user_panel_subscriptions.disburse = ?', true)
    else
      joins(:user_panel_subscription).where('user_panel_subscriptions.disburse = ? or disburse = ?', false, nil)
    end
  }

  scope :filter_expense_management, -> (enabled) {
    if StringUtils.to_bool(enabled)
      joins(:user_panel_subscription).where('user_panel_subscriptions.expense_management = ?', true)
    else
      joins(:user_panel_subscription).where('user_panel_subscriptions.expense_management = ? or expense_management = ?', false, nil)
    end
  }

  scope :filter_vendor_payments, -> (enabled) {
    if StringUtils.to_bool(enabled)
      joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ?', true)
    else
      joins(:user_panel_subscription).where('user_panel_subscriptions.yes_bank_account_transfer = ? or yes_bank_account_transfer = ?', false, nil)
    end
  }

  scope :point_of_contact, -> {
    where point_of_contact: true
  }

  scope :filter_card_number, -> (term) {
    joins(:cards).select('users.*').where('proxy like ?', "%#{term}%")
  }

  scope :includes_for_admin_panel, -> {
    includes(:cards, :company, :profile)
  }

  scope :includes_for_index, -> { includes(:profile) }

  # Gives list of user who are not part of a policy as finance manager
  scope :filter_unassigned_finance_for_policy, -> (policy_id) {
    policy = Policy.find_by id: policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:finance_manager)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  # Gives list of user who are not part of a policy as travel manager
  scope :filter_unassigned_travel_for_policy, -> (policy_id) {
    policy = Policy.find_by id: policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:travel_manager)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  # Gives list of user who are not part of a policy as travel manager
  scope :filter_unassigned_members_for_policy, -> (policy_id) {
    policy = Policy.find_by id: policy_id

    if policy.present?
      user_ids = policy.user_mapping.non_deleted.pluck(:user_id)
      without_id(user_ids)
    end
  }

  # Gives list of user who are not part of a policy as travel manager
  scope :filter_unassigned_creditor_for_policy, -> (policy_id) {
    policy = Policy.find_by id: policy_id

    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy.id).with_role_id(UserRole.id_for(:creditor)).pluck(:user_id)
      without_id(user_ids)
    end

  }

  scope :with_policy_user_roles, -> {
    joins(:policy_user_roles)
  }

  scope :filter_unassigned_purchase_order_initiator_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:purchase_order_initiator)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_purchase_order_reviewer_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:purchase_order_reviewer)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_purchase_order_auditor_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:purchase_order_auditor)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_purchase_request_initiator_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:purchase_request_initiator)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_purchase_request_reviewer_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:purchase_request_reviewer)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_purchase_request_auditor_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:purchase_request_auditor)).pluck(:user_id)
      without_id(user_ids)
    end
  }

    scope :filter_unassigned_goods_receiver_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:goods_receiver)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_invoice_initiator_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:invoice_initiator)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_non_po_invoice_initiator_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:non_po_invoice_initiator)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_po_invoice_initiator_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:po_invoice_initiator)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_invoice_reviewer_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:invoice_reviewer)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_non_po_invoice_reviewer_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:non_po_invoice_reviewer)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_po_invoice_reviewer_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:po_invoice_reviewer)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_bank_payment_request_initiator_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:bank_payment_request_initiator)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_bank_payment_request_reviewer_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:bank_payment_request_reviewer)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_bank_payment_request_creditor_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:bank_payment_request_creditor)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_item_master_manager_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:item_master_manager)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_vendor_creator_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:vendor_creator)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_vendor_reviewer_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:vendor_reviewer)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_vendor_manager_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:vendor_manager)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_budget_manager_for_policy, -> (policy_id) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:budget_manager)).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_unassigned_non_po_initiator_for_policy, -> (policy_id) {
    # policy = Policy.find_by_id policy_id
    # if policy.present?
    #   user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id(UserRole.id_for(:non_po_initiator)).pluck(:user_id)
    #   without_id(user_ids)
    # end
    role_ids = [UserRole.id_for(:non_po_initiator)]
    filter_unassigned_roles_for_policy(policy_id, role_ids)
  }

  scope :filter_unassigned_roles_for_policy, -> (policy_id, role_ids) {
    policy = Policy.find_by_id policy_id
    if policy.present?
      user_ids = PolicyUserRole.with_policy_id(policy_id).with_role_id([role_ids]).pluck(:user_id)
      without_id(user_ids)
    end
  }

  scope :filter_ids, ->(ids) {
    where id: ids
  }

  scope :pending_erp_sync, -> (*args) {
    with_erp_sync_status_pending.active
  }

  before_save :strip_whitespace
  before_save :set_last_activation_deactivation_dates

  around_update :set_passwords_for_linked_users
  after_save :generate_finly_id
  after_create :sync_users_for_group_entity

  after_create do
    default_policy_id = self.company.default_policy.id
    # if the user us added to either one system and not the other, create a default mapping for him or her in both
    if self.team_mapping.expense_management.count == 0
      self.team_mapping.build(default: true, policy_id: default_policy_id, purpose_id: Purpose.id_for(:expense_management)).save
    end
    if self.team_mapping.vendor_payments.count == 0
      self.team_mapping.build(default: true, policy_id: default_policy_id, purpose_id: Purpose.id_for(:vendor_payments)).save
    end
    if self.team_mapping.invoicing.count == 0
      self.team_mapping.build(default: true, policy_id: default_policy_id, purpose_id: Purpose.id_for(:invoice)).save
    end

    self.policy_user_mappings.build(policy_id: default_policy_id).save
    self.build_balance_sheet.save if self.balance_sheet.blank?
    self.build_wallet(balance_attributes: {value: 0, currency_id: Currency.first.id}).save if self.wallet.blank?
    self.build_auto_submit_config(period_id: Period.id_for(:week), enabled: false, limit_to_card_expenses: true).save
    self.build_enforce_policy(enabled: false).save
    self.build_auto_reload_config(enabled: false).save
    self.build_individual_kyc(company_id: self.company_id, kyc_status_id: KycStatus.id_for(:incomplete), admin_review_workflow: AdminReviewWorkflow.workflow_for(:kyc_update)).save if self.individual_kyc.blank?

    # creating the cash on hand account for this user
    self.build_cash_on_hand(balance_attributes: {value: 0, currency_id: Currency.id_for(:INR)}).save
    self.build_bank_wallet(balance_attributes: {value: 0, currency_id: Currency.first.id}).save
    self.build_user_permission(create_beneficiaries: false, company_id: self.company_id).save

    # building a default cash on hand pocket, Card Transfer pocket and Bank Transfer pocket
    self.user_pockets.build(name: "Cash on Hand", user_pocket_type_id: UserPocketType.id_for(:cash), atm_withdrawal_pocket: true, base_currency_id: Currency.first.id, balance_attributes: {value: 0, currency_id: Currency.first.id}).save
    self.user_pockets.build(name: "Reimbursement", user_pocket_type_id: UserPocketType.id_for(:reimbursement), atm_withdrawal_pocket: false, base_currency_id: Currency.first.id, balance_attributes: {value: 0, currency_id: Currency.first.id}).save
    self.user_pockets.build(name: "Paid By Company", user_pocket_type_id: UserPocketType.id_for(:paid_by_company), atm_withdrawal_pocket: false, base_currency_id: Currency.first.id, balance_attributes: {value: 0, currency_id: Currency.first.id}).save
    # self.user_pockets.build(name: "Finly Money - Card Transfer Pocket", user_pocket_type_id: UserPocketType.id_for(:card_transfer), base_currency_id: Currency.first.id, balance_attributes: {value: 0, currency_id: 1}).save
    # self.user_pockets.build(name: "Finly Money - Bank Transfer Pocket", user_pocket_type_id: UserPocketType.id_for(:cash), base_currency_id: Currency.first.id, balance_attributes: {value: 0, currency_id: 1}).save
    #
    # setting the default company_id for this user - if there is already a user added with this company
    if self.company.group_entity_structure_enabled? && self.company.group_id.present? && self.company.group&.default_company_id.present? && self.default_company_id.blank?
      self.update_columns(default_company_id: self.company.group.default_company_id)
    else
      self.update_columns(default_company_id: self.company_id)
    end

  end

  def strip_whitespace
    self.first_name = self.first_name.strip unless self.first_name.nil?
    self.last_name = self.last_name.strip unless self.last_name.nil?
  end

  def set_last_activation_deactivation_dates
    return unless active_changed?

    if active_was
      self.last_deactivated_at = DateTime.now
    else
      self.last_activated_at = DateTime.now
    end
  end

  def password_complexity
    # Regexp extracted from https://stackoverflow.com/questions/19605150/regex-for-password-must-contain-at-least-eight-characters-at-least-one-number-a
    # return if password.blank? || password =~ /(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-])/
    return if password.blank?
    return unless security_policy.gatekeeper.enabled?

    requirement = []
    fail = false
    if security_policy.password.mandate_uppercase?
      requirement << '1 uppercase'
      fail = true unless password =~ /(?=.*?[A-Z])/
    end
    if security_policy.password.mandate_lowercase?
      requirement << '1 lowercase'
      fail = true unless password =~ /(?=.*?[a-z])/
    end
    if security_policy.password.mandate_numbers?
      requirement << '1 digit'
      fail = true unless password =~ /(?=.*?[0-9])/
    end
    if security_policy.password.mandate_special_chars?
      requirement << '1 special character'
      fail = true unless password =~ /(?=.*?[#?!@$%^&*-])/
    end

    if fail
      errors.add :password, "Complexity requirement not met. Requirement: #{requirement.join(', ')}"
    end
  end

  def analytics_id
    "user:#{id}"
  end

  # def min_password_score
  #   level_3_req = UserRole.ids_for(
  #       :admin,
  #       :finance_manager,
  #       :creditor,
  #       :bank_payment_request_creditor
  #   )
  #
  #   level_2_req = UserRole.ids_for(
  #       :auditor,
  #       :manager,
  #       :reviewer,
  #       :purchase_request_reviewer,
  #       :purchase_order_reviewer,
  #       :invoice_reviewer,
  #       :bank_payment_request_reviewer,
  #       :item_master_manager,
  #       :inventory_manager,
  #       :vendor_reviewer,
  #       :policy_admin,
  #       :vendor_manager,
  #       :bank_payment_request_auditor,
  #       :budget_manager
  #   )
  #
  #   return 1 if company_id == 2
  #   return 3 if role_mapping.role(level_3_req).present?
  #   return 2 if role_mapping.role(level_2_req).present?
  #   1
  # end

  def password_expired?
    return false if new_record?
    expire_after = security_policy.password.expire_after
    return false if expire_after.blank?
    (password_changed_at || created_at) < expire_after.seconds.ago
  end

  # Expires user if password is weak, old passwords and inactivity
  def verify_expiration!(password = nil)
    return true if expired? and !otp_verified

    nil_password = password.nil?

    expired = false
    expired ||= expired?
    expired ||= password_expired?
    if password.present?
      self.password = password
      expired ||= password_weak?
    end

    self.password = nil if nil_password

    expire! if expired
    expired
  end

  def expire!
    super and update(otp_verified: false)
  end

  def security_policy
    SecurityPolicy::Manager.for(self)
  end

  def min_password_score
    security_policy.password.minimum_score
  end

  def password_weak?
    password_score.score < min_password_score
  end

  def weak_words
    ['finly.io', 'finly', self.first_name, self.last_name, self.email, self.company&.name, self.company&.name&.split(/\W+/)]
  end

  def payments
    Payment.involving_user(self.id)
  end

  def name
    return "" if first_name.blank? and last_name.blank?
    name = first_name
    "#{first_name} #{last_name}"
  end

  alias_method :requested_by_user_name, :name

  def name_shortened
    "#{first_name[0]}#{last_name[0]}".upcase
  end

  def roles
    self.user_roles
  end

  def expense_management_roles
    role_ids = self.role_mapping.expense_management.pluck(:user_role_id)
    UserRole.where(id: role_ids)
  end

  def vendor_payment_roles
    role_ids = self.role_mapping.vendor_payments.pluck(:user_role_id)
    UserRole.where(id: role_ids)
  end

  def has_application_role?(role_id, application)
    role_id = [role_id] unless role_id.respond_to?(:each)

    purpose_id = nil
    case application.to_s
    when 'em', 'expense_management', Purpose.id_for(:expense_management).to_s
      purpose_id = Purpose.id_for(:expense_management)
    when 'vp', 'vendor_payments', Purpose.id_for(:vendor_payments).to_s
      purpose_id = Purpose.id_for(:vendor_payments)
    else
      return false
    end

    role_mapping.each do |mapping|
      next unless mapping.purpose_id == purpose_id
      next unless role_id.include?(mapping.user_role_id)

      return true
    end
    false
  end

  def company_admin?
    has_application_role?(UserRole.id_for(:admin), :em)
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

  # this method returns if they're an admin in either app, unless specified
  def admin?(application = nil)
    case application.to_s
    when "em"
      company_admin?
    when "vp"
      vendor_payment_admin?
    else
      company_admin? || vendor_payment_admin?
    end
  end

  def finance_manager?
    mapping = self.role_mapping
    mapping.expense_management.finance_manager.present?
  end

  def manager?
    mapping = self.role_mapping
    mapping.expense_management.manager.present?
  end

  def employee?
    mapping = role_mapping
    mapping.expense_management.employee.present? || mapping.vendor_payments.employee.present?
  end

  def auditor?
    mapping = role_mapping
    mapping.auditor.present?
  end

  def travel_manager?
    mapping = role_mapping
    mapping.expense_management.travel_manager.present?
  end

  def vendor_payment_manager?
    self.role_mapping.vendor_payments.manager.present?
  end

  def vendor_payments_auditor?
    self.role_mapping.vendor_payments.auditor.present?
  end

  alias_method :vendor_payments_manager?, :vendor_payment_manager?

  alias_method :vendor_payment_reviewer?, :vendor_payment_manager?
  alias_method :vendor_payments_reviewer?, :vendor_payment_manager?

  def vendor_payment_finance?
    self.role_mapping.vendor_payments.creditor.present? || self.policy_user_roles.with_role_id(UserRole.id_for(:bank_payment_request_creditor)).present?
  end

  alias_method :vendor_payment_finance_manager?, :vendor_payment_finance?
  alias_method :vendor_payment_creditor?, :vendor_payment_finance?
  alias_method :vendor_payments_creditor?, :vendor_payment_finance?

  def vendor_payment_admin?
    has_application_role?(UserRole.id_for(:admin), :vp)
  end

  alias_method :vendor_payments_admin?, :vendor_payment_admin?

  def vendor_payment_initiator?
    self.role_mapping.vendor_payments.initiator.present?
  end

  alias_method :vendor_payments_initiator?, :vendor_payment_initiator?

  def collect_admin?
    self.role_mapping.invoicing.admin.present?
  end

  alias_method :invoicing_admin?, :collect_admin?
  alias_method :finly_collect_admin?, :collect_admin?

  def collect_initiator?
    self.role_mapping.invoicing.initiator.present?
  end

  alias_method :invoicing_initiator?, :collect_initiator?
  alias_method :finly_collect_initiator?, :collect_initiator?

  def expense_management_enabled?
    self.user_panel_subscription.expense_management
  end

  def disburse_enabled?
    self.user_panel_subscription.disburse
  end

  def vendor_payments_enabled?
    self.user_panel_subscription.yes_bank_account_transfer
  end

  alias_method :vendor_payment_enabled?, :vendor_payments_enabled?

  def invoicing_system_enabled?
    self.user_panel_subscription.invoicing_system
  end

  def travel_desk_enabled?
    self.company.travel_desk_enabled? and self.user_panel_subscription.travel_request
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
      return Amount.new(value: 0, currency_id: company.base_currency_id )
    else
      cash_on_hand = history.cash_on_hand_balance
      return cash_on_hand
    end
  end

  alias_method :manager_name, :user_name
  alias_method :finance_manager_name, :user_name
  alias_method :approves_to_name, :user_name
  alias_method :approves_finance_to_name, :user_name
  alias_method :finance?, :finance_manager?

  ransack_scopes :filter_state

  def as_json(options = {})
    {
        id: id,
        name: name,
        email: email,
        mobile_number: mobile_number
    }
  end

  def previous_session
    self.user_sessions.where(admin_user_id: nil).order(id: :desc).offset(1).first
  end

  def json_for_trail(options = {})
    if options[:vendor_show]
      data = {
          id: id,
          name: name,
          email: email,
          employee_id: self.profile&.employee_id,
          mobile_number: self.mobile_number,
          location_name: self.location&.name,
          department_name: self.department&.full_name,
          status: self.active
      }
      return data
    elsif options[:streamsets]
      {
          id: id,
          name: name,
          email: email,
          employee_id: self.profile&.employee_id,
          mobile_number: self.mobile_number,
          location_name: self.location&.name,
          department_name: self.department&.full_name,
          status: self.active,
          full_address: self.profile&.full_address,
          address_1: self.profile&.address_1,
          address_2: self.profile&.address_2,
          pin_code: self.profile&.pin_code,
          city: self.profile&.city,
          state_id: self.profile&.state_id,
          state_name: self.profile&.state_name,
          pan: self.profile&.pan
      }
    else
      {
          id: id,
          name: name,
          email: email
      }
    end
  end

  # overriding devise's default method so that it compares against both email and phone number to authenticate
  def self.find_for_database_authentication(conditions = {})
    return nil if conditions.blank? or conditions[:username].blank?
    username = conditions[:username].delete(' ')
    company_id = conditions[:company_id]
    # company_id = nil
    if company_id.present?
      user = find_by(mobile_number: username, company_id: company_id) || find_by(email: username, company_id: company_id)
    else
      user = find_by(mobile_number: username, active: true) || find_by(email: username, active: true)
      users = User.where(active: true).with_email_or_mobile_number(user&.email, user&.mobile_number)
      default_company_id = users.pluck(:default_company_id).uniq.first
      # if the default_company_id is present then replace the user object returned with the one from the default company
      if default_company_id.present?
        user = find_by(company_id: default_company_id, mobile_number: username) || find_by(company_id: default_company_id, email: username)
      end
    end

    return user if user.present?

    authenticate_with_employee_id(username)
  end

  def self.authenticate_with_employee_id(username)
    employee_id = username
    subdomain = nil
    # Check for subdomain in username
    if not username =~ Constants::VALID_EMAIL_FORMAT and username.include?(".")
      subdomain, employee_id = username.split('.')
    end
    # Check for subdomain from path
    if subdomain.nil? && RequestStoreUtil.current_request&.subdomains(0)&.first.present?
      subdomain = RequestStoreUtil.current_request.subdomains(0)&.first
    end
    return nil if subdomain.blank? or employee_id.blank?

    employee_id = employee_id&.to_s
    Company.find_by(subdomain: subdomain)&.users&.joins(:profile)&.where('user_profiles.employee_id =?', employee_id)&.first
  end

  def manager_activateable?
    !self.default_password and self.email.blank?
  end

  def otp_confirm
    self.update_attributes(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
  end

  def enforce_policy_enabled?
    self.enforce_policy&.enabled
  end

  def superadmin?
    if Constants::SUPERADMIN_ACCOUNTS.include?(self.email)
      true
    else
      false
    end
  end

  def distance_expense_enabled?
    if self.company.distance_expense_enabled? && !self.enforce_policy_enabled?
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
    if self.company.time_expense_enabled? && !self.enforce_policy_enabled?
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

  def vehicle_rates_list
    policies = self.policies
    VehicleRate.with_policy_id(policies.pluck(:id))
  end

  # returns the list of per diems that the user has access to
  def per_diems_list
    per_diems = self.company.per_diems.includes(:rate).active
    policies = self.policies.includes(per_diems: [:rate])
    policies.each do |policy|
      per_diems += policy.per_diems.map { |pd| pd if pd.is_deleted == false }.reject(&:nil?)
    end
    per_diems
  end

  def per_diem_expense_enabled?
    if self.company.per_diem_expense_enabled?
      unless self.enforce_policy_enabled?
        return true
      end
    end
    policies = self.policies
    policies.each do |policy|
      if policy.per_diem_expense_enabled?
        if self.enforce_policy_enabled? && policy.default
          next
        end
        return true
      end
    end
    # if none of the above conditions are satisfied
    false
  end

  # returns the sate of the particular user - active, inactive or pending
  def user_state
    if self.active && !self.default_password && !self.first_name.blank?
      return 1
    elsif self.first_name.nil? || self.default_password
      return 2
    elsif !self.active && !self.first_name.blank?
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

  def payment_initiator?
    self.role_mapping.vendor_payments.employee.present?
  end

  def bank_transfer_enabled?
    (self.vendor_payments_enabled? && self.bank_accounts.present?) || (self.company.bank_reimbursement_enabled?)
  end

  def initials
    (self.name.split(' ').first[0] rescue "") + ((self.name.split(' ')[1][0] rescue nil) or (self.name.split(' ').first[1] rescue ""))
  end

  # method that determines whether a particular user has
  # cash on hand payments that are pending confirmation
  # from the bank - eg. NEFT transfers
  def cash_on_hand_credits_awaiting_confirmation?
    self.receiving_payments.cash_advance.processing.present?
  end

  def reimbursements_awaiting_confirmation?

  end

  def obfuscated_mobile_number
    return nil if mobile_number.nil?

    "XXXXXXX#{mobile_number[(mobile_number.length - 3)..mobile_number.length]}"
  end

  def obfuscated_email
    return nil if email.nil?

    parts = email.split("@")
    return nil if parts.blank?

    obfuscated = "X" * (parts.first.length - 2)
    "#{parts.first[0..2].concat(obfuscated)}@#{parts.second}"
  end

  def status
    "`users`.`active` = 0 AND (NOT ((`users`.`first_name` = '' OR `users`.`first_name` IS NULL)))"
    if self.active and !self.default_password and !(self.first_name.blank? || self.last_name.blank?)
      return "Active"
    elsif self.first_name.blank? || self.default_password
      return "Pending"
    elsif !self.active and !(self.first_name.blank? || self.last_name.blank?)
      return "Inactive"
    end
  end

  def actual_current_user
    RequestStore.store[:actual_current_user]
  end

  def current_user
    RequestStore.store[:current_user]
  end

  # has_roles method is defined to support including policy_user_roles in users to prevent N+1 query problem
  def has_roles?(role_id)
    role_id = [role_id] unless role_id.respond_to?(:each)
    role_id = UserRole.ids_for(role_id) unless role_id.first.is_a?(Integer)
    policy_user_roles.each do |role|
      next unless role.user_id == self.id
      next unless role_id.include?(role.user_role_id)

      return true
    end

    false
    # policy_user_roles.where(user_id: self.id, user_role_id: role_id).count > 0
  end

  def has_policy_role?(role_id, document = nil)
    if document.present?
      policy = Policy.with_company_id(self.company_id).find_by_id document.policy_id
      data = policy.policy_user_roles.where(user_id: self.id, user_role_id: role_id) rescue nil
    else
      if self.enforce_policy_enabled?
        data = self.company.policies.exclude_deleted.where.not(default: true).joins(:policy_user_roles)&.where("(policy_user_roles.user_id = ?) && (policy_user_roles.user_role_id = ?)", self.id, role_id.to_i)
      else
        data = self.company.policies.exclude_deleted.joins(:policy_user_roles)&.where("(policy_user_roles.user_id = ?) && (policy_user_roles.user_role_id = ?)", self.id, role_id.to_i)
      end
    end
    data.present?
  end

  # ********** User Roles for Vendor Payments ******************

  def is_vendor_manager?(document = nil)
    self.has_policy_role?(UserRole.id_for(:vendor_manager), document)
  end

  def is_vendor_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:vendor_creator), document)
  end

  def is_vendor_creator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:vendor_creator), document)
  end

  def is_vendor_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:vendor_reviewer), document)
  end

  def is_vendor_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:vendor_auditor), document)
  end

  def is_item_master_manager?(document = nil)
    self.has_policy_role?(UserRole.id_for(:item_master_manager), document)
  end

  def is_purchase_order_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:purchase_order_initiator), document)
  end

  def is_purchase_order_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:purchase_order_reviewer), document)
  end

  def is_purchase_order_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:purchase_order_auditor), document)
  end

  def is_purchase_request_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:purchase_request_initiator), document)
  end

  def is_purchase_request_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:purchase_request_reviewer), document)
  end

  def is_purchase_request_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:purchase_request_auditor), document)
  end

  def is_bank_payment_request_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator), document)
  end

  def is_bank_payment_request_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer), document)
  end

  def is_bank_payment_request_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor), document)
  end

  def is_bank_payment_request_creditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor), document)
  end

  def is_invoice_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:invoice_initiator), document)
  end

  def is_invoice_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:invoice_reviewer), document)
  end

  def is_invoice_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:invoice_auditor), document)
  end

  def is_budget_manager?(document = nil)
    self.has_policy_role?(UserRole.id_for(:budget_manager), document)
  end

  def is_goods_receiver?(document = nil)
    self.has_policy_role?(UserRole.id_for(:goods_receiver), document)
  end

  def is_inventory_manager?(document = nil)
    self.has_policy_role?(UserRole.id_for(:inventory_manager), document)
  end

  def is_export_manager?(document = nil)
    self.has_policy_role?(UserRole.id_for(:export_manager), document)
  end


  ########### Agreement Based Payments Role End #############
  def is_payment_agreement_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:payment_agreement_initiator), document)
  end

  def is_payment_agreement_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:payment_agreement_reviewer), document)
  end

  def is_payment_agreement_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:payment_agreement_auditor), document)
  end

  def is_agreement_invoice_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:agreement_invoice_initiator), document)
  end

  def is_agreement_invoice_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:agreement_invoice_reviewer), document)
  end

  def is_agreement_invoice_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:agreement_invoice_auditor), document)
  end

  ########### Agreement Based Payments Role End #############

  def is_po_invoice_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:po_invoice_initiator), document)
  end

  def is_po_invoice_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:po_invoice_reviewer), document)
  end

  def is_po_invoice_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:po_invoice_auditor), document)
  end

  def is_non_po_invoice_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:non_po_invoice_initiator), document)
  end

  def is_non_po_invoice_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:non_po_invoice_reviewer), document)
  end

  def is_non_po_invoice_auditor?(document = nil)
    self.has_policy_role?(UserRole.id_for(:non_po_invoice_auditor), document)
  end

  def is_utility_bill_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:utility_bill_initiator), document)
  end

  def is_utility_bill_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:utility_bill_reviewer), document)
  end

  def is_utility_bill_master_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer), document)
  end

  def is_utility_bill_master_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator), document)
  end

  def is_credit_note_initiator?(document = nil)
    self.has_policy_role?(UserRole.id_for(:credit_note_initiator), document)
  end

  def is_credit_note_reviewer?(document = nil)
    self.has_policy_role?(UserRole.id_for(:credit_note_reviewer), document)
  end

  def access_locked?
    locked_at and locked_at > security_policy.account_lock.locking_period.ago
  end

  alias_method :locked?, :access_locked?

  # ************ User Role for vendor payments ******************

  # ************ User Role for expense management ************
  def is_travel_manager?(document = nil)
    self.has_policy_role?(UserRole.id_for(:travel_manager), document)
  end

  # ************ User Role for expense management ************

  def relevant
    {
        email: self.email,
        company_id: self.company_id
    }
  end

  def initiator_for_any_document?
    self.is_purchase_order_initiator? || self.is_invoice_initiator? || self.is_bank_payment_request_initiator? || self.is_item_master_manager? || self.is_vendor_initiator? || self.vendor_payments_admin?
  end

  def vp_admin_or_auditor?
    self.vendor_payments_admin? || self.vendor_payments_auditor?
  end

  def policy_admin_or_auditor?
    self.has_policy_role?(UserRole.id_for(:policy_admin)) || self.has_policy_role?(UserRole.id_for(:policy_auditor))
  end

  # locations associated with policies to which users are associated as initiator role
  def initiator_associated_locations(role_id)
    location_ids = company.policies.joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', role_id).joins(:policy_location_mappings).pluck('policy_location_mappings.location_id')
    return company.locations.with_ids(location_ids)
  end

  # departments associated with policies to which users are associated as initiator role
  def initiator_associated_departments(role_id)
    department_ids = company.policies.joins(:policy_user_roles).where('policy_user_roles.user_role_id = ?', role_id).joins(:policy_department_mappings).pluck('policy_department_mappings.department_id')
    return company.departments.with_ids(department_ids)
  end

  def associated_group_users(exclude_self: false)
    users = User.where(finly_id: self.finly_id)
    users = users.without_id(self.id) if exclude_self
    users
  end

  def associated_group_role_ids
    associated_user_ids = associated_group_users.pluck(:id)
    UserRoleMapping.with_user_id(associated_user_ids).pluck(:user_role_id).uniq + PolicyUserRole.with_user_id(associated_user_ids).pluck(:user_role_id).uniq
  end

  def has_permission?(permissions)
    return true if permissions.blank?

    permissions = [permissions] unless permissions.is_a?(Array)
    permissions = UserRole.ids_for(permissions) unless permissions.first.is_a?(Integer)
    return true if permissions.include?(UserRole.id_for(:admin)) and admin?(RequestStoreUtil.current_app)
    return true if permissions.include?(UserRole.id_for(:vp_admin)) and admin?('vp')
    return true if permissions.include?(UserRole.id_for(:em_admin)) and admin?('em')
    return true if has_roles?(permissions)

    false
  end

  def feature_toggle
    @feature_toggle ||= FeatureToggle.new(self)
  end

  def active?
    active and not default_password and first_name.present? and last_name.present?
  end

  def pending?
    first_name.blank? or default_password
  end

  def inactive?
    first_name.present? and not active
  end

  def deactivated_users_open_invoices
    deactivated_users_ids = company.users.where(active: false).pluck(:id)
    company.inward_invoices.where(invoice_status_id: InwardInvoiceStatus.id_for(:open), created_by: deactivated_users_ids, invoice_type_id: InwardInvoiceType.id_for(:tax_invoice) )
  end

  def non_po_invoice_form_enabled
    feature_flag_enabled = NonPoInvoiceToggle.new(self || RequestStoreUtil.current_user).enabled?
    feature_flag_enabled
  end

  def po_form_enabled
    feature_flag_enabled = PurchaseOrderToggle.new(self || RequestStoreUtil.current_user).enabled?
    feature_flag_enabled
  end

  def po_invoice_form_enabled
    feature_flag_enabled = PoInvoiceToggle.new(self || RequestStoreUtil.current_user).enabled?
    feature_flag_enabled
  end

  def purchase_request_form_enabled
    feature_flag_enabled = PurchaseRequestToggle.new(self || RequestStoreUtil.current_user).enabled?
    feature_flag_enabled
  end

  protected

  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  def set_passwords_for_linked_users
    if encrypted_password_changed?
      reset_passwords = true
    else
      reset_passwords = false
    end
    yield
    if reset_passwords
      if self.company.group_entity_structure_enabled? && self.company.group_id.present?
        group_companies = self.company.group.companies
        other_users = User.with_company_id(group_companies.pluck(:id)).with_email_or_mobile_number(self.email, self.mobile_number).without_id(self.id)
        other_users.each do |user|
          next if user.id == self.id
          user.update_columns(encrypted_password: self.encrypted_password) if user.encrypted_password != self.encrypted_password
          user.update_columns(
              otp: self.otp,
              otp_verified_at: self.otp_verified_at,
              otp_verified: self.otp_verified,
              password_changed_at: self.password_changed_at,
              last_activity_at: self.last_activity_at
          )
        end
      end
    end
  end

  def sync_users_for_group_entity
    return unless self.company.group_entity_structure_enabled? && self.company.group_id.present?

    group_companies = self.company.group.companies
    users = User.with_company_id(group_companies.pluck(:id)).with_email_or_mobile_number(self.email, self.mobile_number).without_id(self.id)
    previously_added_user = users.reorder(created_at: :asc).first # this is the first user added to the system before a new one with the same email ID is added

    return if previously_added_user.blank?
    # setting OTP verified for all users if the current user is verified
    if previously_added_user&.otp_verified?
      users.update_all(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
      self.update_columns(otp: nil, otp_verified_at: DateTime.now, otp_verified: true)
    end
    # setting verified as true for all users if they already exist
    if previously_added_user&.verified
      users.update_all(verified: true)
      self.update_columns(verified: true)
    end
  end

  def generate_finly_id
    return if self.finly_id.present?
    return unless valid?
    ActsAsTenant.without_tenant do
      if self.company.group_entity_structure_enabled? && self.company.group_id.present?
        group_companies = self.company.group.companies
        users = User.with_company_id(group_companies.pluck(:id)).with_email_or_mobile_number(self.email, self.mobile_number).without_id(self.id)
        previously_added_user = users.reorder(created_at: :asc).first #
        self.finly_id = previously_added_user.finly_id if previously_added_user.present? and previously_added_user.finly_id.present?
      end

      # while finly_id.blank? or User.find_by(finly_id: self.finly_id).present?
      #   self.finly_id = UUIDTools::UUID.timestamp_create().to_s.upcase if finly_id.blank?
      # end

      if finly_id.blank?
        while User.find_by(finly_id: self.finly_id).present?
          self.finly_id = UUIDTools::UUID.timestamp_create().to_s.upcase
        end
      end
    end


    unless self.save
      raise "Failed to save unique ID: #{self.errors.full_messages}"
    end
  end

end
