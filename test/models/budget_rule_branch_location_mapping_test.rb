# == Schema Information
#
# Table name: budget_rule_branch_location_mappings
#
#  id                 :bigint           not null, primary key
#  budget_rule_id     :integer          not null
#  branch_location_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class BudgetRuleBranchLocationMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
