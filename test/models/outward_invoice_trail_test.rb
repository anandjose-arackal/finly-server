# == Schema Information
#
# Table name: outward_invoice_trails
#
#  id                              :integer          not null, primary key
#  action_id                       :integer
#  customer_account_transaction_id :integer
#  outward_invoice_id              :integer
#  user_id                         :integer
#  note                            :string(255)
#  amount_id                       :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

require 'test_helper'

class OutwardInvoiceTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
