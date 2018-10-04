# == Schema Information
#
# Table name: sso_keys
#
#  id         :integer          not null, primary key
#  xor_key    :string(255)
#  sha512_key :string(255)
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class SsoKeyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
