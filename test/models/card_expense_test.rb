# == Schema Information
#
# Table name: card_expenses
#
#  id                  :integer          not null, primary key
#  editable_merchant   :text(65535)
#  card_transaction_id :integer
#  expense_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#


require 'test_helper'

class CardExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
