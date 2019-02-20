# == Schema Information
#
# Table name: gatekeeper_blocks
#
#  id         :bigint(8)        not null, primary key
#  user_id    :integer
#  company_id :integer
#  params     :text(65535)
#  headers    :text(65535)
#  act        :string(255)
#  premise    :string(255)
#  verdict    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class GatekeeperBlockTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
