# == Schema Information
#
# Table name: user_groups
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  company_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_deleted :boolean          default(FALSE)
#

require 'test_helper'

class UserGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
