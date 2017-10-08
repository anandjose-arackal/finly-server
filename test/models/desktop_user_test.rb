# == Schema Information
#
# Table name: desktop_users
#
#  id         :integer          not null, primary key
#  email      :string(255)      not null
#  country    :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class DesktopUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
