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

  has_many :initiating_payments, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account

  accepts_nested_attributes_for :configuration
  accepts_nested_attributes_for :itz_cash_property

  after_create :init_config_present

  validates :name, presence: true

  scope :ocr_enabled, -> {joins(:configuration).select(' companies.*').where('ocr_enabled IS true')}

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
    self.configuration.ocr_enabled
  end


  private

  def init_config_present
    self.build_configuration.save unless self.configuration.present?

    self.policies.build(default: true).save unless self.policies.default.present?
    ExportPreference.build_default_preferences(self)
    Constants::DEFAULT_CATEGORIES.each do |category|
      self.categories.create(name: category)
    end

    self.build_account.save if self.account.blank?

    # building the difference expense configurations
    self.build_distance_expense_config(enabled: false).save
    self.build_time_expense_config(enabled: false).save
    self.build_per_diem_expense_config(enabled: false).save
  end

end
