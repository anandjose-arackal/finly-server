# == Schema Information
#
# Table name: custom_fields
#
#  id                     :integer          not null, primary key
#  field_configuration_id :integer          not null
#  parent_id              :integer          not null
#  parent_type            :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value_id               :integer          not null
#  value_type             :string(255)      not null
#

require 'test_helper'

class CustomFieldTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
