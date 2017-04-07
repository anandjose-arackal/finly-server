# == Schema Information
#
# Table name: company_transactions
#
#  id                    :integer          not null, primary key
#  company_id            :integer          not null
#  request_id            :string(255)      not null
#  merchant_name         :string(255)      not null
#  transaction_date      :datetime         not null
#  transaction_amount_id :integer          not null
#  transaction_type      :string(255)      not null
#  transaction_id        :string(255)      not null
#  balance_amount_id     :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  transaction_mode      :string(255)
#  merchant_type_key     :string(255)
#

require 'test_helper'

class CompanyTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
