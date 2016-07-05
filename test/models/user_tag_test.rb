# == Schema Information
#
# Table name: user_tags
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)      not null
#  active     :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class UserTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
