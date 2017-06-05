# == Schema Information
#
# Table name: whitelisted_ips
#
#  id                      :integer          not null, primary key
#  ip_address              :string(255)      not null
#  company_id              :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  whitelisted_ip_types_id :integer          not null
#  whitelisted_ip_type_id  :integer          not null
#

require 'test_helper'

class WhitelistedIpTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
