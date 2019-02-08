# == Schema Information
#
# Table name: user_session_statuses
#
#  id         :bigint(8)        not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class UserSessionStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
