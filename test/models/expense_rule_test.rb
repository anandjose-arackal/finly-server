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
#  deleted_at             :datetime
#

require 'test_helper'

class ExpenseRuleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
