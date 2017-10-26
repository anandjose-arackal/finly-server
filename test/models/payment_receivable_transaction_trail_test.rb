# == Schema Information
#
# Table name: payment_receivable_transaction_trails
#
#  id                          :integer          not null, primary key
#  transaction_id              :integer
#  find_payment_receivable     :boolean
#  creating_payment            :boolean
#  update_company_balance      :boolean
#  payment_receivable_updation :boolean
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

require 'test_helper'

class PaymentReceivableTransactionTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
