# == Schema Information
#
# Table name: itz_cash_properties
#
#  id              :integer          not null, primary key
#  d_code          :string(255)
#  easy_account_no :string(255)
#  company_id      :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'test_helper'

class ItzCashPropertyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
