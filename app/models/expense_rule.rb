# == Schema Information
#
# Table name: expense_rules
#
#  id                     :integer          not null, primary key
#  greater_than_amount_id :integer
#  category_id            :integer
#  days_after             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  rule_type_id           :integer
#  expense_rule_type_id   :integer
#  policy_id              :integer
#  is_deleted             :boolean          default(FALSE)
#








class ExpenseRule < ApplicationRecord
  include SoftDeletable

  belongs_to :greater_than_amount, optional: true, class_name: "Amount", dependent: :destroy
  belongs_to :category, optional: true

  belongs_to :rule_type, optional: true
  belongs_to :expense_rule_type, optional: true
  belongs_to :policy, optional: true

  accepts_nested_attributes_for :greater_than_amount

  delegate :amount_value, to: :greater_than_amount
  delegate :greater_than_amount_value, to: :greater_than_amount
  delegate :type, to: :rule_type
  delegate :category_name, to: :category

  default_scope { unscope(:where)}

  validates :policy_id, presence: true
  validates :rule_type_id, presence: true
  validates :expense_rule_type_id, presence: true

  validate :no_duplicates

  before_create :update_parent_version
  before_destroy :update_parent_version

  has_paper_trail

  scope :warning_rules, -> {
    where rule_type_id: RuleType.warning_rule_id
  }

  scope :blocking_rules, -> {
    where rule_type_id: RuleType.blocking_rule_id
  }

  # Amount currency is always picked up from base currency of the policy
  def greater_than_amount
    return super if super.nil?
    Amount.new(value: super.value, currency_id: self.policy.base_currency_id)
  end

  def rule_in_words
    rule_in_words = "Expenses"
    if self.category_id
      rule_in_words += " belonging to category " + self.category_name
    end
    if self.days_after
      rule_in_words += " submitted after " + self.days_after.to_s + " days"
    end
    if self.greater_than_amount_id and self.greater_than_amount_value > 0
      rule_in_words += " with amount greater than #{self.greater_than_amount.currency.symbol}#{self.amount_value.to_s} #{self.greater_than_amount.currency.country_code}"
    end
    case self.expense_rule_type_id
      when 1
        rule_in_words += " require a receipt."
      when 2
        rule_in_words += " require a note."
      when 3
        rule_in_words += " are not allowed"
      when 4
        rule_in_words += " require receipt hard copy submission."
    end
    rule_in_words
  end

  private
  def update_parent_version
    self.policy.update_attribute(:updated_at, DateTime.now)
  end

  # todo - look for a more elegant way to do this. Shitty code.
  # make sure no rule has all attributes the same
  def no_duplicates
    self.policy.expense_rules.exclude_deleted.each do |rule|
      if not rule.id == self.id and rule.amount_value == self.amount_value and rule.category_id == self.category_id and rule.days_after == self.days_after and rule.expense_rule_type_id == self.expense_rule_type_id and rule.rule_type_id == self.rule_type_id
        errors.add(:rule, 'already exists. Please try again.')
      end
    end

  end

end
