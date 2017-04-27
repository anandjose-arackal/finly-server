# == Schema Information
#
# Table name: itz_cash_card_programs
#
#  id           :integer          not null, primary key
#  product_code :string(255)
#  charge_code  :string(255)
#  name         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bank         :string(255)
#

require 'test_helper'

class ItzCashCardProgramTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
