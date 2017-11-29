# == Schema Information
#
# Table name: virtual_account_collect_trails
#
#  id                     :integer          not null, primary key
#  found_virtual_account  :boolean
#  update_company_balance :boolean
#  create_payment         :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  account_transaction_id :integer
#  note                   :text(65535)
#

require 'test_helper'

class VirtualAccountCollectTrailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
