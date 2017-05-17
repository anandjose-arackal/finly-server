# == Schema Information
#
# Table name: per_diem_expense_configs
#
#  id         :integer          not null, primary key
#  enabled    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  policy_id  :integer          not null
#

require 'test_helper'

class PerDiemExpenseConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
