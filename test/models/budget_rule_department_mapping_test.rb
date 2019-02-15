# == Schema Information
#
# Table name: budget_rule_department_mappings
#
#  id             :bigint(8)        not null, primary key
#  budget_rule_id :integer          not null
#  department_id  :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class BudgetRuleDepartmentMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
