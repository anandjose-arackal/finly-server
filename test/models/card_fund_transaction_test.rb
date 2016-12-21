# == Schema Information
#
# Table name: card_fund_transactions
#
#  id              :integer          not null, primary key
#  transaction_id  :string(255)      not null
#  response        :text(65535)      not null
#  action          :string(255)      not null
#  requesting_user :integer          not null
#  for_user        :integer          not null
#  post_params     :text(65535)      not null
#  post_url        :text(65535)      not null
#  amount_value    :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class CardFundTransactionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
