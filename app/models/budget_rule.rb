# == Schema Information
#
# Table name: budget_rules
#
#  id                   :integer          not null, primary key
#  category_id          :integer
#  amount_id            :integer
#  period_id            :integer
#  policy_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  rule_type_id         :integer
#  include_reimbursable :boolean          default(TRUE)
#  is_deleted           :boolean          default(FALSE)
#  expense_type_id      :integer
#







# expense_type_id: contains details about whether the budget is scoped to a particular
# type of expense or not
# 1 - Manual, 2 - Card, 3 - Distance, 4 - Time, 5 - Per Diem

class BudgetRule < ActiveRecord::Base
  include SoftDeletable

  belongs_to :category
  belongs_to :amount, dependent: :destroy
  belongs_to :period
  belongs_to :policy
  belongs_to :rule_type

  accepts_nested_attributes_for :amount

  # delegate :period, to: :period
  delegate :type, to: :rule_type
  delegate :amount_value, to: :amount
  delegate :category_name, to: :category

  default_scope { unscope(:where)}

  validates :period_id, presence: true
  validates :policy_id, presence: true
  validates :rule_type_id, presence: true

  validate :no_duplicates

  before_create :update_parent_version
  before_destroy :update_parent_version

  has_paper_trail

  def include_reimbursable_expenses?
    self.include_reimbursable
  end

  def rule_in_words
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
    if self.category_id
      rule_in_words += " belonging to category " + self.category_name
    end
    if self.amount_id
      rule_in_words += " should not exceed #{self.amount.currency.symbol}#{self.amount_value.to_s} #{self.amount.currency.country_code}"
    end
    rule_in_words
  end

  private
  def update_parent_version
    self.policy.update_attribute(:updated_at, DateTime.now)
  end

  # todo - look for a more elegant way to do this. Shitty code.
  def no_duplicates
    # checking against all budget rules in the respective policy
    self.policy.budget_rules.exclude_deleted.each do |rule|
      if not rule.id == self.id and rule.amount_value == self.amount_value and rule.category_id == self.category_id and rule.period_id == self.period_id and rule.rule_type_id == self.rule_type_id
        errors.add(:rules, 'already exists. Please try again.')
      end
    end
  end

end
