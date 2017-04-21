# == Schema Information
#
# Table name: itz_cash_dmt_senders
#
#  id              :integer          not null, primary key
#  username        :string(255)      not null
#  mobile_number   :string(255)      not null
#  registration_id :string(255)      not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class ItzCashDmtSenderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
