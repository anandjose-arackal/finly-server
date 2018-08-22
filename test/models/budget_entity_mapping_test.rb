# == Schema Information
#
# Table name: budget_criteria_mappings
#
#  id              :integer          not null, primary key
#  budget_id       :integer
#  budgetable_id   :integer
#  budgetable_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class BudgetEntityMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
