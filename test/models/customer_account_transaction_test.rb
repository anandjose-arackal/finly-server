# == Schema Information
#
# Table name: customer_account_transactions
#
#  id                     :integer          not null, primary key
#  customer_account_id    :integer
#  transaction_type       :string(255)
#  transaction_amount_id  :integer
#  note                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  associated_object_id   :integer
#  associated_object_type :string(255)
#

require 'test_helper'

class CustomerAccountTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
