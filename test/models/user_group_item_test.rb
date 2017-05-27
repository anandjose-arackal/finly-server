# == Schema Information
#
# Table name: user_group_items
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  user_group_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  is_deleted    :boolean          default(FALSE)
#

require 'test_helper'

class UserGroupItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
