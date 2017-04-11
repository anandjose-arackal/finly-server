# == Schema Information
#
# Table name: per_diem_expenses
#
#  id          :integer          not null, primary key
#  per_diem_id :integer
#  expense_id  :integer
#  quantity    :integer
#  is_deleted  :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class PerDiemExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
