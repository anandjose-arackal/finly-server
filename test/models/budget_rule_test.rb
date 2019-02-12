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

require 'test_helper'

class BudgetRuleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
