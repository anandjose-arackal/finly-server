# == Schema Information
#
# Table name: finly_transactions
#
#  id                          :integer          not null, primary key
#  finly_account_id            :integer          not null
#  finly_account_type          :string(255)      not null
#  transaction_type_id         :integer          not null
#  amount_id                   :integer          not null
#  transaction_reference_id    :string(255)      not null
#  status_id                   :integer          not null
#  payment_purpose_id          :integer          not null
#  opening_balance_id          :integer
#  closing_balance_id          :integer
#  associated_transaction_id   :integer
#  associated_transaction_type :string(255)
#  payment_id                  :integer
#  company_id                  :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  date                        :datetime
#

require 'test_helper'

class FinlyTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
