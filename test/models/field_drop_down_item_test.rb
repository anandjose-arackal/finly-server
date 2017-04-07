# == Schema Information
#
# Table name: field_drop_down_items
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  field_configuration_id :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'test_helper'

class FieldDropDownItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
