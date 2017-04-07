# == Schema Information
#
# Table name: per_diem_expense_configs
#
#  id          :integer          not null, primary key
#  parent_id   :integer
#  parent_type :string(255)
#  enabled     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class PerDiemExpenseConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
