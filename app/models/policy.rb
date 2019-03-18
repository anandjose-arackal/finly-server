# == Schema Information
#
# Table name: policies
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  company_id             :integer
#  owner_id               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  default                :boolean          default(FALSE), not null
#  is_deleted             :boolean          default(FALSE), not null
#  description            :text(65535)
#  base_currency_id       :integer          default(1)
#  application            :string(255)
#  settlement_currency_id :integer          default(1), not null
#  deleted_at             :datetime
#

class Policy < ApplicationRecord
  include SoftDeletable

  belongs_to :company, optional: true
  belongs_to :base_currency, optional: true, class_name: 'Currency'
  belongs_to :settlement_currency, optional: true, class_name: 'Currency'
  has_one :configuration, class_name: 'PolicyConfiguration', dependent: :destroy
  has_many :user_mapping, class_name: 'PolicyUserMapping', dependent: :destroy
  has_many :users, -> { where(:'policy_user_mappings.deleted_at' => nil)}, through: :user_mapping
  has_many :user_team_mapping, class_name: 'UserManagerMapping', dependent: :destroy

  has_many :reports
  has_many :money_requests

  has_many :expense_rules, dependent: :destroy
  has_many :budget_rules, dependent: :destroy
  has_many :policy_user_roles, dependent: :destroy

  has_one :distance_expense_config
  has_one :time_expense_config
  has_one :per_diem_expense_config
  has_one :cash_expense_config
  has_one :card_expense_config

  has_many :per_diems, as: :configurable
  has_many :vehicle_rates

  scope :default, -> {where default: true}
  scope :non_default, -> {where default: false}
  scope :company, ->(company_id) {where company_id: company_id}
  scope :by_name, ->(name) {where name: name}
  scope :with_id, -> (id) {where id: id}
  scope :without_id, ->(id) {where.not id: id}
  scope :not_deleted, -> {where is_deleted: false}
  scope :find_from_id, -> (id) {find_by(id: id)}
  scope :with_application, -> (application) {where( application: application).or(default)}
  scope :without_settlement_currency_id, ->(currency_id) {where.not settlement_currency_id: currency_id}
  scope :include_user_mapping, -> { includes :user_mapping }

  delegate :expense_rules_count, to: :expense_rules
  delegate :budget_rules_count, to: :budget_rules

  # has_many :field_configurations, as: :configurable
  has_many :policy_field_mappings
  has_many :field_configurations, through: :policy_field_mappings
  has_many :levels, class_name: 'ReviewalLevel', dependent: :destroy
  has_many :level_user_reviewer_mappings, dependent: :destroy


  validates :company_id, presence: true
  validate :one_default_per_company

  # Set base currency ID as INR unless set explicitly
  before_save {self.base_currency_id = Currency.id_for(:INR) if self.base_currency_id.blank?}

  after_create :initialize_expense_configs

  default_scope {order('policies.created_at ASC')}

  def admins
    admin_mapping_ids = self.user_mapping.admin.pluck(:user_id)
    User.where(id: admin_mapping_ids)
  end

  after_create do
    self.build_configuration.save unless self.configuration.present?
  end

  def expense_rules_count
    self.expense_rules.non_deleted.count
  end

  def budget_rules_count
    self.budget_rules.non_deleted.count
  end

  def rules_count
    (self.expense_rules.count + self.budget_rules.count)
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

  def as_json(options = {})
    {
        id: id,
        name: name
    }
  end

  private

  def one_default_per_company
    if default
      default_policy = Policy.company(company_id).without_id(self.id).default
      errors.add(:company, 'cannot have more than one default policy') if default_policy.present? and default_policy != self
    end
  end

  def initialize_expense_configs
    # building the different expense configurations
    self.build_distance_expense_config(enabled: false).save
    self.build_time_expense_config(enabled: false).save
    self.build_per_diem_expense_config(enabled: false).save
    self.build_cash_expense_config(enabled: true).save
    self.build_card_expense_config(enabled: true).save
  end

end
