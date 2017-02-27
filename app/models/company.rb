# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  active     :boolean          default(TRUE), not null
#  d_code     :string(255)
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

  accepts_nested_attributes_for :configuration
  accepts_nested_attributes_for :itz_cash_property

  delegate :d_code, :easy_account_no, to: :itz_cash_property

  after_create :init_config_present

  validates :name, presence: true

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

  private

  def init_config_present
    self.build_configuration.save unless self.configuration.present?

    self.policies.build(default: true).save unless self.policies.default.present?
    ExportPreference.build_default_preferences(self)
    Constants::DEFAULT_CATEGORIES.each do |category|
      self.categories.create(name: category)
    end

    self.build_account.save if self.account.blank?
  end

end
