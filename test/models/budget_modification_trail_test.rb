# == Schema Information
#
# Table name: budget_modification_trails
#
#  id             :integer          not null, primary key
#  budget_id      :integer
#  action_user_id :integer
#  action_id      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class BudgetModificationTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
