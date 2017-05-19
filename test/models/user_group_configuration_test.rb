# == Schema Information
#
# Table name: user_group_configurations
#
#  id         :integer          not null, primary key
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  type_id    :integer          not null
#

require 'test_helper'

class UserGroupConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
