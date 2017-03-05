# == Schema Information
#
# Table name: field_configurations
#
#  id                   :integer          not null, primary key
#  enabled              :boolean          default(TRUE), not null
#  field_type_id        :integer          not null
#  mandatory            :boolean          default(FALSE), not null
#  company_id           :integer          not null
#  field_parent_type_id :integer          not null
#  configurable_id      :integer          not null
#  configurable_type    :string(255)      not null
#  default_value        :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  field_name           :string(255)      not null
#

require 'test_helper'

class FieldConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
