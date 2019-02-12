# == Schema Information
#
# Table name: user_group_item_mappings
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  user_group_item_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_deleted         :boolean          default(FALSE)
#  user_group_id      :integer
#  deleted_at         :datetime
#

require 'test_helper'

class UserGroupItemMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
