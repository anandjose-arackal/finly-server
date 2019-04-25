# == Schema Information
#
# Table name: per_diem_expenses
#
#  id          :integer          not null, primary key
#  per_diem_id :integer
#  expense_id  :integer
#  quantity    :decimal(10, 4)
#  is_deleted  :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

require 'test_helper'

class PerDiemExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
