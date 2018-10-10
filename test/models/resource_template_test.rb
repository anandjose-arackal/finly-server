# == Schema Information
#
# Table name: resource_templates
#
#  id            :integer          not null, primary key
#  name          :string(255)      not null
#  resource_type :string(255)      not null
#  user_id       :integer          not null
#  last_used_at  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class ResourceTemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
