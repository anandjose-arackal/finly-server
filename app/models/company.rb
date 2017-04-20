# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  active     :boolean          default(TRUE), not null
#

class Company < ActiveRecord::Base
  include Constants

  has_many :users
  has_many :cards
  has_many :contacts, as: :contactable
  has_many :categories, dependent: :destroy
  has_many :tags, class_name: 'CompanyTag', dependent: :destroy
  has_one :configuration, class_name: 'CompanyConfiguration', dependent: :destroy
  has_many :policies, dependent: :destroy
  has_many :export_preferences, dependent: :destroy
  has_one :account, class_name: 'CompanyAccount'
  has_many :fund_load_requests, class_name: 'CompanyFundsLoadRequest'
  has_one :itz_cash_property
  has_many :company_transactions


  has_one :distance_expense_config, as: :parent
  has_one :time_expense_config, as: :parent
  has_one :per_diem_expense_config, as: :parent

  has_many :per_diems, as: :configurable

  has_many :company_balance_histories

  has_many :field_configurations, as: :configurable

  has_one :feature_subscription, as: :subscribable

  has_many :initiating_payments, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account
  
  has_many :payment_orders

  accepts_nested_attributes_for :configuration
  accepts_nested_attributes_for :itz_cash_property
  accepts_nested_attributes_for :feature_subscription

  after_create :init_config_present

  validates :name, presence: true

  scope :with_id, -> (id) {where id: id}
  scope :ocr_enabled, -> { joins(:feature_subscriptions).select(' companies.*').where('ocr_enabled IS true') }

  scope :filter_search, -> (term) {
    where('name LIKE (?)', "%#{term}%")
  }

  scope :created_between, -> (start_date, end_date) {
    where('created_at >= ? && created_at <= ?', start_date, end_date)
  }

  def default_policy
    self.policies.default
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
    self.distance_expense_config.enabled
  end

  def time_expense_enabled?
    self.time_expense_config.enabled
  end

  def per_diem_expense_enabled?
    self.per_diem_expense_config.enabled
  end

  def ocr_enabled?
    self.feature_subscription.ocr_enabled
  end

  def balance_amount(date)
    balance_history = self.company_balance_histories.with_date(date).first rescue nil
    return 0 if balance_history.nil?
    return balance_history.company_balance_value
  end

  def d_code_assigned?
    self.itz_cash_property&.d_code.present?
  end


  private

  def init_config_present
    # self.build_configuration(ocr_enabled: false).save unless self.configuration.present?

    self.policies.build(default: true).save unless self.policies.default.present?
    ExportPreference.build_default_preferences(self)
    Constants::DEFAULT_CATEGORIES.each do |category|
      self.categories.create(name: category)
    end

    self.build_configuration.save if self.configuration.blank?
    self.build_account.save if self.account.blank?

    # building the difference expense configurations
    self.build_distance_expense_config(enabled: false).save
    self.build_time_expense_config(enabled: false).save
    self.build_per_diem_expense_config(enabled: false).save

    if self.feature_subscription.blank?
      self.build_feature_subscription.save
    end
  end

end
