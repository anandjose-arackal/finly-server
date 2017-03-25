# == Schema Information
#
# Table name: transcribed_expenses
#
#  id         :integer          not null, primary key
#  amount_id  :integer
#  date       :date
#  merchant   :text(65535)
#  note       :text(65535)
#  receipt_id :integer
#  expense_id :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class TranscribedExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
