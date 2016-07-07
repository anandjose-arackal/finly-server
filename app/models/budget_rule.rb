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
  belongs_to :category
  belongs_to :amount
  belongs_to :budget_period
  belongs_to :policy
  belongs_to :rule_type

  accepts_nested_attributes_for :amount, :budget_period

  delegate :period, to: :budget_period
  delegate :type, to: :rule_type
end
