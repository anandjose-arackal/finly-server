# == Schema Information
#
# Table name: field_configurations
#
#  id                      :integer          not null, primary key
#  enabled                 :boolean          default(TRUE), not null
#  field_type_id           :integer          not null
#  mandatory               :boolean          default(FALSE), not null
#  company_id              :integer          not null
#  configurable_id         :integer
#  configurable_type       :string(255)      not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  field_name              :string(255)      not null
#  default_value_id        :integer
#  default_value_type      :string(255)
#  is_deleted              :boolean          default(FALSE), not null
#  global                  :boolean          default(TRUE)
#  external_reference_type :string(255)
#  external_reference_id   :integer
#  parent_id               :integer
#  parent_type             :string(255)
#  root_field              :boolean          default(TRUE)
#  field_key               :string(255)
#  sequence_number         :integer
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

  test 'setting default value for fields configuration: Text: Success' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:text),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value 'abc'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldText'
    assert field_configuration.default_value.kind_of?(FieldText)
    assert_equal field_configuration.default_value.value, 'abc'
  end

  test 'setting default value for fields configuration: Number: Success' do
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
    assert field_configuration.default_value.kind_of?(FieldNumber)
    assert_equal field_configuration.default_value.value_as_number, 200
  end

  test 'Setting default value for fields configuration: Decimal: Success' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:decimal),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '200.10'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldDecimal'
    assert field_configuration.default_value.kind_of?(FieldDecimal)
    assert_equal field_configuration.default_value.value_as_decimal, 200.10
  end

  test 'Setting default value for fields configuration: Boolean: Success' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:boolean),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value 'true'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldBoolean'
    assert field_configuration.default_value.kind_of?(FieldBoolean)
    assert_equal field_configuration.default_value.value, true
  end

  test 'Setting default value for fields configuration: Date: Success' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:date),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '12 Jan 2017 +5:30'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldDate'
    assert field_configuration.default_value.kind_of?(FieldDate)
    assert_equal field_configuration.default_value.value_as_date, '12 Jan 2017'
  end

  test 'Setting default value for fields configuration: DateTime: Success' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:datetime),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '08:30 AM, 12 Jan 2017 +5:30'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldDateTime'
    assert field_configuration.default_value.kind_of?(FieldDateTime)
    assert_equal field_configuration.default_value.value_as_datetime, '08:30 AM, 12 Jan 2017'
  end

  test 'Creating drop-down field configuration requires creating dropdown items' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:drop_down),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    assert_not field_configuration.valid?
    assert_not field_configuration.save

    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:drop_down),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable, drop_down_items_attributes: [{name: 'a'}, {name: 'b'}]}
    field_configuration = FieldConfiguration.new param
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert_equal field_configuration.drop_down_items.count, 2
    assert_equal field_configuration.drop_down_items.first.name, 'a'
    assert_equal field_configuration.drop_down_items.second.name, 'b'

  end

  test 'Setting default value for fields configuration: Amount: Success' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:amount),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '100'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldAmount'
    assert field_configuration.default_value.kind_of?(FieldAmount)
    assert_equal field_configuration.default_value.value_amount.to_f, 100.to_f
  end

  test 'Updating default value for amount field should update the same existing objects and not create new ones' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:amount),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '100'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert_equal field_configuration.default_value.value_amount.to_f, 100.to_f

    object_id = field_configuration.default_value.value.id
    field_configuration.set_default_value '200'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert_equal field_configuration.default_value.value_amount.to_f, 200.to_f
    assert_equal field_configuration.default_value.value.id, object_id
  end

  test 'If default drop down selection is not present among the field configurations, it should fail' do
    FieldConfiguration.any_instance.stubs(:drop_down_items => stub(:with_id => stub(:present? => false)))

    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:drop_down),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '1'
    assert_not field_configuration.valid?
    assert_not field_configuration.save
  end

  test 'Setting default value for fields configuration: Dropdown' do
    FieldConfiguration.any_instance.stubs(:drop_down_items => stub(:with_id => stub(:present? => true)))

    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:drop_down),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '1'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.present?
    assert_equal field_configuration.default_value_type, 'FieldDropDownSelection'
    assert field_configuration.default_value.kind_of?(FieldDropDownSelection)
    assert_equal field_configuration.default_value.value_id, 1
  end

  test 'Updating field value should update in the same table' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:text),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value 'abc'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload

    # Updating value
    original_field_id = field_configuration.default_value_id
    field_configuration.set_default_value '12345ad'
    assert field_configuration.save
    field_configuration.reload
    assert_equal field_configuration.default_value_id, original_field_id
    assert_equal field_configuration.default_value.value, '12345ad'
  end

  test 'If default value is updated to nil, then the field should be destroyed' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:text),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value 'abc'
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload

    # Updating value to nil
    original_field = field_configuration.default_value
    field_configuration.set_default_value nil
    assert field_configuration.save
    field_configuration.reload
    assert_nil field_configuration.default_value_id
    record_not_found_exception = false
    begin
      original_field.reload
    rescue ActiveRecord::RecordNotFound
      record_not_found_exception = true
    end
    assert record_not_found_exception
  end

  test 'setting default value for fields configuration: Text: Failure' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:text),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value nil
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
    assert field_configuration.default_value_id.nil?
  end

  test 'entering invalid format for default value should throw an error' do
    name = 'Test name'
    configurable = Company.first
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:number),
             field_parent_type_id: FieldParentType.id_for(:report), configurable: configurable}
    field_configuration = FieldConfiguration.new param
    field_configuration.set_default_value '12abd'
    assert_not field_configuration.valid?
  end

  test 'expense configuration can only be added at an organisation level' do
    name = 'Test name'
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:number),
             field_parent_type_id: FieldParentType.id_for(:expense), configurable_id: 1, configurable_type: 'Policy'}
    field_configuration = FieldConfiguration.new param
    assert_not field_configuration.valid?
    assert_not field_configuration.save

    name = 'Test name'
    param = {company: Company.first, field_name: name, enabled: true, field_type_id: FieldType.id_for(:number),
             field_parent_type_id: FieldParentType.id_for(:expense), configurable_id: 1, configurable_type: 'Company'}
    field_configuration = FieldConfiguration.new param
    assert field_configuration.valid?
    assert field_configuration.save
    field_configuration.reload
    assert field_configuration.id.present?
  end

end
