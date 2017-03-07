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
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  field_name           :string(255)      not null
#  default_value_id     :integer
#  default_value_type   :string(255)
#

require 'test_helper'

class FieldConfigurationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup

  end

  test 'successful creation' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:number),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert_equal field_configuration.field_name, name
    assert_equal field_configuration.mandatory, false
    assert_nil field_configuration.default_value
  end

  test 'setting default value for fields configuration' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:number),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '200'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldNumber'
    debugger
    assert field_configuration.default_value.kind_of?(FieldNumber)
    assert_equal field_configuration.default_value.value_as_number, 200
  end

end
