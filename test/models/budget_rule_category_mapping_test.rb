# == Schema Information
#
# Table name: budget_rule_category_mappings
#
#  id             :integer          not null, primary key
#  budget_rule_id :integer          not null
#  category_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class BudgetRuleCategoryMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
