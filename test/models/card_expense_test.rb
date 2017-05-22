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
#  surcharge_id        :integer
#  is_deleted          :boolean          default(FALSE)
#  cancelled           :boolean          default(FALSE)
#  atm_surcharge       :boolean          default(FALSE)
#


require 'test_helper'

class CardExpenseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
