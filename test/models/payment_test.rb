# == Schema Information
#
# Table name: payments
#
#  id                 :integer          not null, primary key
#  amount_id          :integer          not null
#  date               :date             not null
#  payment_type_id    :integer          not null
#  initiating_user_id :integer          not null
#  receiving_user_id  :integer          not null
#  note               :text(65535)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#


require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
