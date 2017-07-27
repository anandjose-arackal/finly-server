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
#

class Company < ActiveRecord::Base
  include Constants

  belongs_to :base_currency, class_name: 'Currency'
  has_many :users
  has_many :cards
  has_many :contacts, as: :contactable
  has_many :categories, dependent: :destroy
  has_many :tags, class_name: 'CompanyTag', dependent: :destroy
  has_one :configuration, class_name: 'CompanyConfiguration', dependent: :destroy
  has_many :policies, dependent: :destroy
  has_many :export_preferences, dependent: :destroy
  has_one :account, class_name: 'CompanyAccount'
  has_one :quickbooks_configuration
  has_many :fund_load_requests, class_name: 'CompanyFundsLoadRequest'
  has_one :itz_cash_property
  has_many :company_transactions
  has_many :per_diems, as: :configurable
  has_many :company_balance_histories
  has_many :field_configurations, as: :configurable
  has_one :feature_subscription, as: :subscribable

  has_many :payment_orders
  has_many :user_groups
  has_many :user_teams
  has_many :auto_sync_configs
  has_many :quickbooks_payment_types
  has_one :company_kyc
  has_many :card_assign_requests
  has_many :card_upgrade_requests
  has_many :individual_kycs

  accepts_nested_attributes_for :configuration
  accepts_nested_attributes_for :itz_cash_property
  accepts_nested_attributes_for :feature_subscription
  accepts_nested_attributes_for :auto_sync_configs
  accepts_nested_attributes_for :company_kyc

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

  scope :filter_search, -> (term) {
    where('name LIKE (?)', "%#{term}%")
  }

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

  def hard_copy_receipt_enabled?
    self.feature_subscription.hard_copy_receipt
  end

  def itz_cash_d_code_enabled?
    self.feature_subscription.itz_cash_d_code_enabled
  end

  def more_than_one_subscription?
    count = 0
    [:expense_management_enabled, :gift_card_enabled, :medical_card_enabled, :fuel_card_enabled, :meal_card_enabled, :expense_card_enabled, :reimbursement_card_enabled].each do |feature|
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


  private

  def init_config_present

    self.policies.build(default: true, name: 'Company (Default)').save unless self.policies.default.present?
    ExportPreference.build_default_preferences(self)
    Constants::DEFAULT_CATEGORIES.each do |category|
      self.categories.create(name: category)
    end

    self.build_configuration.save if self.configuration.blank?
    self.build_account.save if self.account.blank?

    if self.feature_subscription.blank?
      self.build_feature_subscription.save
    end

    # create the auto sync configurations for each new company
    AutoSyncConfigType::VALUES.each do |type|
      self.auto_sync_configs.build(enabled: false)
    end

    self.build_company_kyc(kyc_status_id: KycStatus.id_for(:incomplete)).save if self.company_kyc.blank?
  end

end
