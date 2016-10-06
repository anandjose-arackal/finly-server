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

require 'test_helper'

class BudgetRuleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
