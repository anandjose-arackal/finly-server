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
  belongs_to :amount
  belongs_to :category

  belongs_to :rule_type
  belongs_to :expense_rule_type
end
