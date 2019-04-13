# == Schema Information
#
# Table name: companies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  active           :boolean          default(TRUE), not null
#  base_currency_id :integer          default(1)
#  status_id        :integer          default(1), not null
#

class Company < ApplicationRecord
  include Constants

  belongs_to :base_currency, optional: true, class_name: 'Currency'
  belongs_to :status, optional: true, class_name: 'CompanyStatus'

  has_many :users
  has_many :cards
  has_many :contacts, as: :contactable
  has_many :categories, dependent: :destroy
  has_many :cost_centers, dependent: :destroy
  has_many :tags, class_name: 'CompanyTag', dependent: :destroy
  has_one :configuration, class_name: 'CompanyConfiguration', dependent: :destroy
  has_many :policies, dependent: :destroy
  has_many :export_preferences, dependent: :destroy
  has_one :account, class_name: 'CompanyAccount'
  has_one :quickbooks_configuration
  has_one :tally_configuration
  has_one :accounting_system_configuration
  has_many :fund_load_requests, class_name: 'CompanyFundsLoadRequest'
  has_one :itz_cash_property
  has_many :company_transactions
  has_many :per_diems, as: :configurable
  has_many :company_balance_histories
  has_many :all_field_configurations, class_name: 'FieldConfiguration'
  has_many :field_configurations, as: :configurable
  has_many :bank_transactions
  has_many :items
  has_many :payment_terms
  has_many :tds_slabs, class_name: "TdsRatesList"
  has_many :tax_rates
  has_many :invoice_reminders
  has_many :invoice_number_configs
  has_one :feature_subscription, as: :subscribable
  has_one :itz_cash_company_account
  has_one :yes_bank_company_account
  has_one :payment_file_configuration
  has_one :collect_auto_transfer_config, class_name: "CompanyFundsAutoTransferConfig"
  has_many :web_hooks
  has_many :web_hook_tracks
  has_many :invoice_attachments
  has_many :export_configs

  has_one :collect_credit_account, class_name: "BankAccount", as: :account_owner
  has_one :collect_company_detail
  has_one :enforce_budget_configuration
  has_one :custom_export_configuration, as: :configurable

  has_many :payment_orders
  has_many :user_groups
  has_many :user_teams
  has_many :auto_sync_configs
  has_many :quickbooks_payment_types
  has_one :company_kyc
  has_many :card_assign_requests
  has_many :card_upgrade_requests
  has_many :individual_kycs
  has_many :yes_bank_vendors
  has_many :vendor_types
  has_many :bank_accounts
  has_many :quickbooks_departments
  has_many :report_processor_groups
  has_many :money_request_processors
  has_many :payment_receivables
  has_many :virtual_bank_accounts
  has_many :customers
  has_many :outward_invoices
  has_many :outward_invoice_attachments
  has_many :inward_invoices, class_name: "Invoice"
  has_many :money_request_item_categories

  has_many :budgets
  has_many :procurements
  has_many :procurement_terms
  has_many :procurement_attachments
  has_many :document_number_configs
  has_many :purchase_orders
  has_many :purchase_requests
  has_many :inward_documents # purchase order inward documents
  has_many :field_customizations, as: :scopable

  has_many :departments
  has_many :company_pocket_templates

  has_many :booking_attachments
  has_many :locations, class_name: "BranchLocation"
  has_many :bank_payment_requests
  has_many :attachments, as: :resource, dependent: :nullify


  accepts_nested_attributes_for :configuration
  accepts_nested_attributes_for :itz_cash_property
  accepts_nested_attributes_for :feature_subscription
  accepts_nested_attributes_for :auto_sync_configs
  accepts_nested_attributes_for :company_kyc

  delegate :bank_type, to: :configuration

  after_create :init_config_present

  validates :name, presence: true

  scope :with_id, -> (id) { where id: id }
  scope :filter_ocr, -> (flag) {
    if flag == '1'
      joins(:feature_subscription).select('companies.*').where('ocr_enabled IS true')
    elsif flag == '0'
      joins(:feature_subscription).select('companies.*').where('ocr_enabled IS false OR ocr_enabled IS NULL')
    end
  }

  scope :filter_cards, -> (flag) {
    if flag == '1'
      joins(:itz_cash_property).select('companies.*').where.not("itz_cash_properties.d_code = '' OR itz_cash_properties.d_code IS NULL")
    elsif flag == '0'
      joins(:itz_cash_property).select('companies.*').where("itz_cash_properties.d_code = '' OR itz_cash_properties.d_code IS NULL")
    end
  }
  scope :ocr_enabled, -> { joins(:feature_subscription).select(' companies.*').where('ocr_enabled IS true') }

  scope :filter_status_id, -> (status_id) { where status_id: status_id }

  scope :filter_search, -> (term) {
    where('name LIKE (?)', "%#{term}%")
  }

  # scope :filter_active, -> (val) { where(active: true, partial_block: false, hidden: false) if val }
  # scope :filter_deactivate, -> (val) { where(active: false) if val }
  # scope :filter_partial_block, -> (val) { where(active: true, partial_block: true) if val }
  # scope :filter_hidden, -> (val) { where(active: true, partial_block: true) if val }

  scope :created_between, -> (date_from, date_to) {
    unless date_from.blank? && date_to.blank?
      type_val = :created_at
      date_from = "1990-01-01" if date_from.blank?
      date_to = DateUtils.local_date if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date if date_to.present?
      companies = arel_table
      where(companies[type_val].gteq(date_from).and(companies[type_val].lteq(date_to)))
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

  scope :auto_sync_categories_enabled, -> {
    joins(:auto_sync_configs).select('companies.*').where(categories_sync: true)
  }

  scope :auto_sync_company_tags_enabled, -> {
    joins(:auto_sync_configs).select('companies.*').where(company_tags_sync: true)
  }

  scope :auto_sync_external_users_enabled, -> {
    joins(:auto_sync_configs).select('companies.*').where(external_users_sync: true)
  }

  scope :auto_sync_reports_enabled, -> {
    joins(:auto_sync_configs).select('companies.*').where(reports_sync: true)
  }

  def vendor_payment_policies
    ids = self.policies.with_application("vp").pluck(:id)
    ids << self.default_policy.id
    Policy.where(id: ids)
  end

  def default_policy
    self.policies.default&.first
  end

  def get_active_users
    self.users.where(active: true)
  end

  def active_categories
    # using the categories scope active
    self.categories.active
  end

  def company_name
    self.name
  end

  def admins
    users.with_roles.only_admins
  end

  def managers
    users.with_roles.only_managers
  end

  def finance_managers
    users.with_roles.only_finance_managers
  end

  def d_code
    return nil if itz_cash_property.blank?
    itz_cash_property.d_code
  end

  def hdfc?
    self.configuration.bank_type.upcase == "HDFC"
  end

  def rbl?
    self.configuration.bank_type.upcase == "RBL"
  end

  def easy_account_no
    return nil if itz_cash_property.blank?
    itz_cash_property.easy_account_no
  end

  def distance_expense_enabled?
    self.default_policy.distance_expense_config.enabled
  end

  def time_expense_enabled?
    self.default_policy.time_expense_config.enabled
  end

  def per_diem_expense_enabled?
    self.default_policy.per_diem_expense_config.enabled
  end

  def ocr_enabled?
    self.feature_subscription.ocr_enabled
  end

  # Feature subscription methods
  def expense_management_enabled?
    self.feature_subscription.expense_management_enabled
  end

  def bank_reimbursement_enabled?
    self.feature_subscription.bank_account_reimbursement || vendor_payments_enabled?
  end

  def gift_card_enabled?
    self.feature_subscription.gift_card_enabled
  end

  def gift_voucher_enabled?
    self.feature_subscription.gift_voucher_enabled
  end

  def meal_card_enabled?
    self.feature_subscription.meal_card_enabled
  end

  def fuel_card_enabled?
    self.feature_subscription.fuel_card_enabled
  end

  def medical_card_enabled?
    self.feature_subscription.medical_card_enabled
  end

  def expense_card_enabled?
    self.feature_subscription.expense_card_enabled
  end

  def reimbursement_card_enabled?
    self.feature_subscription.reimbursement_card_enabled
  end

  def em_tax_tracking_enabled?
    self.feature_subscription.em_tax_tracking
  end

  def payroll_card_enabled?
    self.feature_subscription.payroll_card_enabled
  end

  def hard_copy_receipt_enabled?
    self.feature_subscription.hard_copy_receipt
  end

  def itz_cash_d_code_enabled?
    self.feature_subscription.itz_cash_d_code_enabled
  end

  def cards_enabled?
    expense_card_enabled? || medical_card_enabled? || reimbursement_card_enabled? || gift_card_enabled? || gift_voucher_enabled? || meal_card_enabled?
  end

  def vendor_payments_enabled?
    self.feature_subscription.yes_bank_account
  end

  def yes_bank_account_enabled?
    self.feature_subscription.yes_bank_account || self.feature_subscription.bank_account_reimbursement
  end

  def current_account_connected?
    self.feature_subscription.current_account_connected
  end

  def invoicing_system_enabled?
    self.feature_subscription.invoicing_system
  end

  def travel_desk_enabled?
    self.feature_subscription.travel_request
  end

  def procurement_enabled?
    self.feature_subscription.procurement
  end

  def budgeting_system_enabled?
    self.feature_subscription.budgeting_system
  end

  def vendor_empanelment_workflow_enabled?
    self.feature_subscription.vendor_empanelment_workflow
  end

  def more_than_one_subscription?
    count = 0
    [:expense_management_enabled, :gift_card_enabled, :medical_card_enabled, :fuel_card_enabled, :meal_card_enabled, :expense_card_enabled, :reimbursement_card_enabled, :yes_bank_account].each do |feature|
      if self.feature_subscription.send(feature)
        count += 1
      end
    end
    if count >= 2
      return true
    else
      return false
    end
  end


  def balance_amount(date)
    balance_history = self.company_balance_histories.with_date(date).first rescue nil
    return 0 if balance_history.nil?
    return balance_history.company_balance_value
  end

  def d_code_enabled?
    !!self.feature_subscription.d_code_enabled? || !!self.itz_cash_property&.d_code.present?
  end

  def accepted_agreements?
    poc = self.users.point_of_contact.first
    user_agreement = CompanyAgreementTrack.with_user(poc.id)
    if user_agreement.empty?
      return false
    end
    true
  end

  def kyc_required?
    return false unless feature_subscription.d_code_enabled?
    if [KycStatus.id_for(:incomplete), KycStatus.id_for(:submitted), KycStatus.id_for(:rejected)].include?(company_kyc.kyc_status_id)
      return true
    end
    false
  end

  def kyc_completed?
    !!self.company_kyc&.completed?
  end

  def company_type
    self.company_kyc&.company_type&.name
  end

  def yes_bank_account_number
    self.yes_bank_company_account.account_number
  end

  def all_policies
    policy_ids = self.policies.default.pluck(:id)
    policy_ids += self.policies.with_application(RequestStore[:current_app]).pluck(:id)
    Policy.with_id(policy_ids)
  end

  def dep_subdept_mapping
    result = {}
    departments = user.company.departments
    sub_departments = user.company.departments.only_sub_departments
    departments.each do |department|
      
    end
  end

  private

  def init_config_present

    self.policies.build(default: true, name: 'Company (Default)').save unless self.policies.default.present?
    ExportPreference.build_default_preferences(self)
    Constants::DEFAULT_CATEGORIES.each do |category|
      self.categories.create(name: category, expense_management: true, vendor_payments: true)
    end

    Constants::DEFAULT_MONEY_REQUEST_CATEGORIES.each do |category|
      self.money_request_item_categories.create(name: category, active: true)
    end

    self.build_configuration(bank_type: "HDFC").save if self.configuration.blank?
    # also setting the default card transaction category here, so even if 'Other' is renamed later, it
    # will not matter for the same
    other_category = self.categories.find_by(name: "Other")
    self.configuration.update(default_card_expense_category_id: other_category&.id)

    self.build_account.save if self.account.blank?

    if self.feature_subscription.blank?
      self.build_feature_subscription.save
    end

    # create the auto sync configurations for each new company
    AutoSyncConfigType::VALUES.each do |type|
      self.auto_sync_configs.build(enabled: false)
    end

    self.build_company_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save if self.company_kyc.blank?
    self.build_itz_cash_company_account(balance_attributes: {value: 0, currency_id: Currency.first.id}).save
    self.build_yes_bank_company_account(balance_attributes: {value: 0, currency_id: Currency.first.id}).save

    # creating the invoice numbering configuration for all companies with default values
    # self.build_invoice_number_config(sequence_start: "0000").save
    self.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:tax_invoice)}).save
    self.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:advance)}).save
    self.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:credit_note)}).save
    self.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:collect), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:debit_note)}).save
    self.invoice_number_configs.build({sequence_start: "0000", purpose_id: Purpose.id_for(:vendor_payments), invoice_number_config_type_id: InvoiceNumberConfigType.id_for(:debit_note)}).save

    # Seed Default list of vendor types
    default_vendor_types = %w( Contractors Vendors )
    default_vendor_types.each do |vendor_type|
      self.vendor_types.build({name: vendor_type}).save
    end

    # creating budget configurations
    self.build_enforce_budget_configuration(enforce_purchase_order_budget: false, enforce_payment_budget: false,
                                               enforce_expense_budget: false, enforce_invoice_budget: false).save

    # creating custom export configurations for a company
    self.build_custom_export_configuration(custom_report: false, custom_invoice: false, custom_purchase_order: false).save


    # Create Invoicing System Auto transfer config (enabled: false)
    self.build_collect_auto_transfer_config.save


    self.build_collect_company_detail.save
    # seeding the default payment terms for this company
    PaymentTerm.seed_defaults(self.id)
    TdsRatesList.seed_data(self.id)
  end

end
