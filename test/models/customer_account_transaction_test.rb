# == Schema Information
#
# Table name: customer_account_transactions
#
#  id                             :integer          not null, primary key
#  customer_account_id            :integer
#  transaction_type               :string(255)
#  virtual_account_transaction_id :integer
#  transaction_amount_id          :integer
#  note                           :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#

require 'test_helper'

class CustomerAccountTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
