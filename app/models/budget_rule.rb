# == Schema Information
#
# Table name: budget_rules
#
#  id                        :integer          not null, primary key
#  category_id               :integer
#  amount_id                 :integer
#  period_id                 :integer
#  policy_id                 :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  rule_type_id              :integer
#  include_reimbursable      :boolean          default(TRUE)
#  is_deleted                :boolean          default(FALSE)
#  expense_type_id           :integer
#  with_receipt_amount_id    :integer
#  without_receipt_amount_id :integer
#  deleted_at                :datetime
#

# expense_type_id: contains details about whether the budget is scoped to a particular
# type of expense or not
# 1 - Manual, 2 - Card, 3 - Distance, 4 - Time, 5 - Per Diem

class BudgetRule < ApplicationRecord
  include SoftDeletable

  # belongs_to :category, optional: true
  has_many :budget_rule_category_mappings
  has_many :categories, through: :budget_rule_category_mappings
  belongs_to :amount, optional: true, dependent: :destroy
  belongs_to :period, optional: true
  belongs_to :policy, optional: true
  belongs_to :rule_type, optional: true
  belongs_to :with_receipt_amount, optional: true, class_name: 'Amount'
  belongs_to :without_receipt_amount, optional: true, class_name: 'Amount'
  has_many :budget_rule_field_mappings
  has_many :field_drop_down_items, through: :budget_rule_field_mappings
  has_many :field_configurations, through: :budget_rule_field_mappings

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :with_receipt_amount
  accepts_nested_attributes_for :without_receipt_amount
  accepts_nested_attributes_for :budget_rule_field_mappings
  accepts_nested_attributes_for :budget_rule_category_mappings

  # delegate :period, to: :period
  delegate :type, to: :rule_type
  delegate :amount_value, to: :amount, allow_nil: true
  # delegate :category_name, to: :category

  default_scope {unscope(:where)}

  validates :period_id, presence: true
  validates :policy_id, presence: true
  validates :rule_type_id, presence: true

  validate :no_duplicates
  validate :amount_presence

  before_create :update_parent_version
  before_destroy :update_parent_version

  scope :with_id, -> (id) {where id: id}
  scope :without_id, -> (id) {where.not id: id}
  scope :warning_rules, -> {where rule_type_id: RuleType.warning_rule_id}

  scope :blocking_rules, -> {where rule_type_id: RuleType.blocking_rule_id}

  def include_reimbursable_expenses?
    self.include_reimbursable
  end

  # Amount currency is always picked up from base currency of the policy
  def amount
    return nil if super.nil?
    Amount.new(value: super.value, currency_id: self.policy.base_currency_id)
  end

  # Amount currency is always picked up from base currency of the policy
  def with_receipt_amount
    return nil if super.nil?
    Amount.new(value: super.value, currency_id: self.policy.base_currency_id)
  end

  # Amount currency is always picked up from base currency of the policy
  def without_receipt_amount
    return nil if super.nil?
    Amount.new(value: super.value, currency_id: self.policy.base_currency_id)
  end

  def rule_in_words(options = {})
    case self.expense_type_id
    when 1
      type = "of Cash"
    when 2
      type = "of Card"
    when 3
      type = "of Distance"
    when 4
      type = "of Time"
    when 5
      type = "of Per Diem"
    else
      type = ""
    end
    rule_in_words = "Total #{type} Expenses"
    if self.period_id
      case self.period_id
      when 1
        period = "day"
      when 2
        period = "week"
      when 3
        period = "month"
      when 4
        period = "year"
      else
        period = ""
      end
      rule_in_words += " per " + period
    end
    if self.categories.present?
      rule_in_words += " belonging to category "
      self.categories.each do |category|
        if category.parent.present?
          rule_in_words += "#{category.parent.name} - "
        end
        rule_in_words += "#{category.name}"
        unless self.categories.last == category
          rule_in_words += ','
        end
      end
    end
    # if self.category_id
    #   rule_in_words += " for category " + self.category_name
    # end
    if self.budget_rule_field_mappings.present?
      field_config_map = {}
      self.budget_rule_field_mappings.each do |mapping|
        if field_config_map[mapping.field_configuration.field_name].nil?
          field_config_map[mapping.field_configuration.field_name] = []
        end
        field_config_map[mapping.field_configuration.field_name] << mapping.field_drop_down_item.name
      end
      field_config_map.each do |field_name, field_values|
        rule_in_words += " having #{field_name} "
        if field_values.size > 1
          rule_in_words += " in #{field_values.join(', ')}"
        else
          rule_in_words += " as #{field_values.first}"
        end
      end
    end

    if options&.dig(:violation)
      rule_in_words += " have exceeded"
    else
      rule_in_words += " should not exceed"
    end

    if self.amount_id
      rule_in_words += " #{self.amount.currency.symbol}#{self.amount_value.to_s} #{self.amount.currency.country_code}"
      if options&.dig(:exceeded_by)
        rule_in_words += " by #{self.amount.currency.symbol}#{options&.dig(:exceeded_by)} #{self.amount.currency.country_code}"
      end
    else
      with_receipt_presence = self.with_receipt_amount_id.present?
      if self.with_receipt_amount_id and (not options&.dig(:violation) or (options[:violation_type] == :with_receipt))
        rule_in_words += " #{self.with_receipt_amount.currency.symbol}#{self.with_receipt_amount.value.to_s} #{self.with_receipt_amount.currency.country_code}"
        if options&.dig(:exceeded_by)
          rule_in_words += " by #{self.with_receipt_amount.currency.symbol}#{options&.dig(:exceeded_by)} #{self.with_receipt_amount.currency.country_code}"
        end
        rule_in_words += " with receipt"
      end
      if self.without_receipt_amount_id and (not options&.dig(:violation) or (options[:violation_type] == :without_receipt))
        if with_receipt_presence and not options&.dig(:violation)
          rule_in_words += ' and'
        end
        rule_in_words += " #{self.without_receipt_amount.currency.symbol}#{self.without_receipt_amount.value.to_s} #{self.without_receipt_amount.currency.country_code}"
        if options&.dig(:exceeded_by)
          rule_in_words += " by #{self.without_receipt_amount.currency.symbol}#{options&.dig(:exceeded_by)} #{self.without_receipt_amount.currency.country_code}"
        end
        rule_in_words += " without receipt"
      end
    end
    rule_in_words
  end

  private

  def update_parent_version
    self.policy.update_attribute(:updated_at, DateTime.now)
  end

  def amount_presence
    if amount.blank? and without_receipt_amount.blank? and with_receipt_amount.blank?
      errors.add :amount, 'is not defined'
    end
  end

  # todo - look for a more elegant way to do this. Shitty code.
  def no_duplicates
    # checking against all budget rules in the respective policy
    self.policy.budget_rules.exclude_deleted.each do |rule|
      next if rule.id == self.id
      next unless rule.amount_value == self.amount_value
      rule_category_ids = rule.categories.pluck(:id)
      category_ids = self.categories.pluck(:id)
      next unless rule_category_ids.size == category_ids and (rule_category_ids - category_ids).blank?
      next unless rule.period_id == self.period_id
      next unless rule.rule_type_id == self.rule_type_id
      errors.add(:rules, 'already exists. Please try again.')
      # if not rule.id == self.id and rule.amount_value == self.amount_value and
      #     rule.categories.pluck(:id) == self.categories.pluck(:id) and rule.period_id == self.period_id and rule.rule_type_id == self.rule_type_id
      #   errors.add(:rules, 'already exists. Please try again.')
      # end
    end
  end

end
