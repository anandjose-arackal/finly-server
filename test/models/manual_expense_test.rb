# == Schema Information
#
# Table name: manual_expenses
#
#  id         :integer          not null, primary key
#  expense_id :integer
#  merchant   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_deleted :boolean          default(FALSE)
#  deleted_at :datetime
#


require 'test_helper'

class ManualExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
