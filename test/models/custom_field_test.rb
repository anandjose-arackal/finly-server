# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  field_configuration_id :integer          not null
#  parent_id              :integer
#  parent_type            :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value_id               :integer
#  value_type             :integer
#

require 'test_helper'

class CustomFieldTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
