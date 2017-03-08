require 'test_helper'

class CreateTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @company = Company.first
    @policy = Policy.first
    @user_2 = User.second
    # :field_title, :enabled, :field_type_id, :mandatory,
    #     :field_parent_type_id, :configurable, :configurable_id, :configurable_type,
    #     :default_value, :company,
    #     amount_attributes: [:value, :currency],
    #     drop_down_items_attributes:[:name]
  end

  test 'successful creation of field_configuration at a company level' do
    valid_params = {field_configuration: {field_name: 'Test Title', field_type_id: 2, mandatory: false,
                                           default_value: 10, field_parent_type_id: FieldParentType.id_for(:report),
                                           configurable_id: @company.id, configurable_type: 'Company'}}
    result = nil
    assert_difference 'FieldConfiguration.count', 1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?
    assert result.field_configuration.present?
    assert result.field_configuration.id.present?
    assert result.field_configuration.reload.present?
    assert_equal result.field_configuration.reload.field_name, 'Test Title'
    assert @company.field_configurations.with_id(result.field_configuration.id).present?
  end

  test 'successful creation of field_configuration at policy level' do
    valid_params = {field_configuration: {field_name: 'Test Title Policy', field_type_id: 4, mandatory: false,
                                          default_value: 'true', field_parent_type_id: FieldParentType.id_for(:expense),
                                          configurable_id: @policy.id, configurable_type: 'Policy'}}
    result = nil
    assert_difference 'FieldConfiguration.count', 1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?
    assert result.field_configuration.present?
    assert result.field_configuration.id.present?
    assert result.field_configuration.reload.present?
    assert_equal result.field_configuration.reload.field_name, 'Test Title Policy'
    assert @policy.field_configurations.with_id(result.field_configuration.id).present?
  end

  test 'successful creation of field_configuration at user level' do
    valid_params = {field_configuration: {field_name: 'Test Title User', field_type_id: 1,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'User'}}
    result = nil
    assert_difference 'FieldConfiguration.count', 1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?
    assert result.field_configuration.present?
    assert result.field_configuration.id.present?
    assert result.field_configuration.reload.present?
    assert_equal result.field_configuration.mandatory, false
    assert_equal result.field_configuration.reload.field_name, 'Test Title User'
    assert @user_2.field_configurations.with_id(result.field_configuration.id).present?
  end

  test 'not wrapping the configuration in field_configuration should fail' do
    valid_params = {field_name: 'Test Title User', field_type_id: 1, mandatory: false,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'User'}
    result = nil
    assert_no_difference 'FieldConfiguration.count' do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.failure?
  end

  test 'Field name is required to create field configuration' do
    valid_params = {field_configuration: {field_type_id: 1, mandatory: false,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'User'}}
    result = nil
    assert_no_difference 'FieldConfiguration.count' do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.failure?
  end

  test 'Field parent type id is required to create field configuration' do
    valid_params = {field_configuration: {field_type_id: 1,
                                          configurable_id: @user_2.id, configurable_type: 'User'}}
    result = nil
    assert_no_difference 'FieldConfiguration.count' do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.failure?

    valid_params = {field_configuration: {field_name: 'Test Title User', field_type_id: 1, field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'User'}}
    assert_difference 'FieldConfiguration.count', 1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?
    assert result.field_configuration.present?
    assert result.field_configuration.id.present?
    assert result.field_configuration.reload.present?
    assert_equal result.field_configuration.mandatory, false
    assert_equal result.field_configuration.reload.field_name, 'Test Title User'
    assert @user_2.field_configurations.with_id(result.field_configuration.id).present?
  end

  test 'Configurable ID required to create field configuration' do
    valid_params = {field_configuration: {field_name: 'test field', field_type_id: 1, mandatory: false,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_type: 'User'}}
    result = nil
    assert_no_difference 'FieldConfiguration.count' do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.failure?
  end

  test 'Configurable Type required to create field configuration' do
    valid_params = {field_configuration: {field_name: 'test field', field_type_id: 1, mandatory: false,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'Payment'}}
    result = nil
    assert_no_difference 'FieldConfiguration.count' do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.failure?

    valid_params = {field_configuration: {field_name: 'test field', field_type_id: 1, mandatory: false,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'User'}}
    result = nil
    assert_difference 'FieldConfiguration.count',1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?

    valid_params = {field_configuration: {field_name: 'test field', field_type_id: 1, mandatory: false,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'Policy'}}
    result = nil
    assert_difference 'FieldConfiguration.count',1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?

    valid_params = {field_configuration: {field_name: 'test field', field_type_id: 1, mandatory: false,
                                          default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                                          configurable_id: @user_2.id, configurable_type: 'Company'}}
    result = nil
    assert_difference 'FieldConfiguration.count',1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?
  end

  test 'When default value is set, a new default value object is created' do
    valid_params = {field_configuration: {field_name: 'Test Title', field_type_id: FieldType.id_for(:decimal), mandatory: false,
                                          default_value: '10.1001', field_parent_type_id: FieldParentType.id_for(:report),
                                          configurable_id: @company.id, configurable_type: 'Company'}}
    result = nil
    assert_difference 'FieldConfiguration.count', 1 do
      result = CustomField::Configuration::Create.(@user, valid_params)
    end
    assert result.success?
    assert result.field_configuration.reload.present?
    assert result.field_configuration.default_value.present?
    assert result.field_configuration.default_value.kind_of?(FieldDecimal)
    assert_equal result.field_configuration.default_value.value_as_decimal, 10.1001
  end

end