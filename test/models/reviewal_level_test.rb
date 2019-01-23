# == Schema Information
#
# Table name: reviewal_levels
#
#  id                     :integer          not null, primary key
#  level_number           :integer
#  policy_id              :integer
#  associated_entity_type :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  is_deleted             :boolean          default(FALSE), not null
#  deleted_at             :datetime
#

require 'test_helper'

class ReviewalLevelTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
