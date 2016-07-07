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
#

class ExpenseRule < ActiveRecord::Base
  belongs_to :greater_than_amount, class_name: "Amount"
  belongs_to :category

  belongs_to :rule_type
  belongs_to :expense_rule_type
  belongs_to :policy

  accepts_nested_attributes_for :greater_than_amount

  delegate :amount_value, to: :greater_than_amount
  delegate :type, to: :rule_type
end
