# == Schema Information
#
# Table name: group_item_configuration_mappings
#
#  id                 :integer          not null, primary key
#  configuration_id   :integer          not null
#  user_group_id      :integer          not null
#  user_group_item_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  type_id            :integer          not null
#

require 'test_helper'

class GroupItemConfigurationMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
