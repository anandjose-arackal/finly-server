# == Schema Information
#
# Table name: distance_expenses
#
#  id          :integer          not null, primary key
#  expense_id  :integer
#  is_deleted  :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  distance_id :integer
#

require 'test_helper'

class DistanceExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
