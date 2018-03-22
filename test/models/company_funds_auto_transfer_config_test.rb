# == Schema Information
#
# Table name: company_funds_auto_transfer_configs
#
#  id                   :integer          not null, primary key
#  company_id           :integer
#  threshold_amount_id  :integer
#  frequency_name       :string(255)
#  frequency_day        :string(255)
#  amount_transfer_type :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  enabled              :boolean          default(FALSE)
#

require 'test_helper'

class CompanyFundsAutoTransferConfigTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
