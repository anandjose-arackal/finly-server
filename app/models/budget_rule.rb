# == Schema Information
#
# Table name: budget_rules
#
#  id               :integer          not null, primary key
#  category_id      :integer
#  amount_id        :integer
#  budget_period_id :integer
#  policy_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  rule_type_id     :integer
#

class BudgetRule < ActiveRecord::Base
  include PolicyVersion
  belongs_to :category
  belongs_to :amount
  belongs_to :budget_period
  belongs_to :policy
  belongs_to :rule_type

  accepts_nested_attributes_for :amount

  delegate :period, to: :budget_period
  delegate :type, to: :rule_type
  delegate :amount_value, to: :amount
  delegate :category_name, to: :category

  validates :amount_id, presence: true
  validates :budget_period_id, presence: true
  validates :policy_id, presence: true
  validates :rule_type_id, presence: true

  validate :no_duplicates

  private

  # todo - look for a more elegant way to do this. Shitty code.
  def no_duplicates
    # checking against all budget rules in the respective policy
    self.policy.budget_rules.each do |rule|
      if rule.amount_value == self.amount_value and rule.category_id == self.category_id and rule.budget_period_id == self.budget_period_id and rule.rule_type_id == self.rule_type_id
        errors.add(:rule, 'already exists. Please try again.')
      end
    end
  end

end
