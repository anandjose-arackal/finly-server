# == Schema Information
#
# Table name: budget_rule_field_mappings
#
#  id                      :integer          not null, primary key
#  budget_rule_id          :integer          not null
#  field_configuration_id  :integer          not null
#  field_drop_down_item_id :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'test_helper'

class BudgetRuleFieldMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
