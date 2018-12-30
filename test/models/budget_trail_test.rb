# == Schema Information
#
# Table name: budget_trails
#
#  id                :integer          not null, primary key
#  entity_id         :integer
#  entity_type       :string(255)
#  category_id       :integer
#  cost_center_id    :integer
#  location_id       :integer
#  vendor_id         :integer
#  amount_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer
#  department_id     :integer
#  date              :date
#  sub_department_id :integer
#  procurement_id    :integer
#

require 'test_helper'

class BudgetTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
