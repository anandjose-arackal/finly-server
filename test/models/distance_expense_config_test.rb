# == Schema Information
#
# Table name: distance_expense_configs
#
#  id                  :integer          not null, primary key
#  parent_id           :integer
#  parent_type         :string(255)
#  rate_per_km         :decimal(10, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  enabled             :boolean
#  default_category_id :integer
#

require 'test_helper'

class DistanceExpenseConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
