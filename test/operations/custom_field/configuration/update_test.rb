require 'test_helper'

require 'minitest/unit'
require 'mocha/mini_test'

class UpdateTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @user.stubs(:company_admin? => true)
    @company = Company.first
    @policy = Policy.first
    @user_2 = User.second
    @field_configuration = FieldConfiguration.new(field_name: 'Old Test Title', field_type_id: FieldType.id_for(:number), mandatory: false,
                                                  field_parent_type_id: FieldParentType.id_for(:report), company_id: 1,
                                                  configurable_id: @company.id, configurable_type: 'Company')
    @field_configuration.save
    @id = @field_configuration.id
  end

  test 'successful update of field_configuration at a company level' do
    assert @id.present?

    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    old_field_name = @field_configuration.field_name
    new_field_name = 'New Test Title'
    assert_not_equal old_field_name, new_field_name

    valid_params = {field_configuration: {id: @id, field_name: new_field_name}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert result.field_configuration.present?
    assert result.field_configuration.id.present?
    assert result.field_configuration.reload.present?
    assert_equal result.field_configuration.reload.field_name, new_field_name
    assert_equal result.field_configuration.field_parent_type_id, FieldParentType.id_for(:report)
    assert_equal result.field_configuration.field_type_id, FieldType.id_for(:number)
    assert @company.field_configurations.with_id(result.field_configuration.id).present?
  end

  test 'not wrapping the configuration in field_configuration should fail' do
    valid_params = {field_name: 'Test Title User', field_type_id: 1, mandatory: false,
                    default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
                    configurable_id: @policy.id, configurable_type: 'Policy'}
    result = nil
    assert_no_difference 'FieldConfiguration.count' do
      result = CustomField::Configuration::Update.(@user, valid_params)
    end
    assert result.failure?
  end

  test 'Field name is required to update field configuration' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    valid_params = {id: @id, field_name: 'New Test Title 2'}

    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.failure?
  end

  test 'When default value is set, if no default value is present a new default value object is updated' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    assert @field_configuration.default_value.blank?
    assert_equal @field_configuration.field_type_id, FieldType.id_for(:number)

    valid_params = {field_configuration: {id: @id, default_value: '10'}}
    result = nil
    assert_difference 'FieldNumber.count', 1 do
      result = CustomField::Configuration::Update.(@user, valid_params)
    end
    assert result.success?
    assert result.field_configuration.reload.present?
    assert result.field_configuration.default_value.present?
    assert result.field_configuration.default_value.kind_of?(FieldNumber)
    assert_equal result.field_configuration.default_value.value_as_number, 10
  end

  test 'When default value is set, if default value is present, the same value is updated with the new value' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))
    old_default_value = 10
    @field_configuration.set_default_value old_default_value
    assert @field_configuration.save
    assert @field_configuration.default_value_id.present?
    old_default_value_id = @field_configuration.default_value_id
    assert_equal @field_configuration.field_type_id, FieldType.id_for(:number)

    valid_params = {field_configuration: {id: @id, default_value: '11'}}
    result = nil
    assert_no_difference 'FieldNumber.count' do
      result = CustomField::Configuration::Update.(@user, valid_params)
    end
    assert result.success?
    assert result.field_configuration.reload.present?
    assert result.field_configuration.default_value.present?
    assert result.field_configuration.default_value.kind_of?(FieldNumber)
    assert_equal result.field_configuration.default_value.value_as_number, 11
    assert_equal result.field_configuration.default_value_id, old_default_value_id
  end

  test 'Field Type ID cannot be updated' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    old_field_type_id = @field_configuration.field_type_id
    new_field_type_id = FieldType.id_for(:text)
    assert_not_equal new_field_type_id, old_field_type_id

    valid_params = {field_configuration: {id: @id, field_type_id: new_field_type_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.failure?
    assert_equal @field_configuration.reload.field_type_id, old_field_type_id

    valid_params = {field_configuration: {id: @id, field_name: 'New Name', field_type_id: new_field_type_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert_equal result.field_configuration.field_name, 'New Name'
    assert_equal result.field_configuration.field_type_id, old_field_type_id
  end

  test 'Field Parent Type cannot be updated' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    old_field_parent_type_id = @field_configuration.field_parent_type_id
    new_field_parent_type_id = FieldParentType.id_for(:expense)
    assert_not_equal old_field_parent_type_id, new_field_parent_type_id

    valid_params = {field_configuration: {id: @id, field_parent_type_id: new_field_parent_type_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.failure?
    assert_equal @field_configuration.reload.field_parent_type_id, old_field_parent_type_id

    valid_params = {field_configuration: {id: @id, field_name: 'New Name2', field_parent_type_id: new_field_parent_type_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert_equal result.field_configuration.field_name, 'New Name2'
    assert_equal result.field_configuration.field_parent_type_id, old_field_parent_type_id
  end

  test 'Field Configurable Type cannot be updated' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    old_field_configurable_type = @field_configuration.configurable_type
    new_field_configurable_type = 'Policy'
    assert_not_equal old_field_configurable_type, new_field_configurable_type

    valid_params = {field_configuration: {id: @id, configurable_type: new_field_configurable_type}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.failure?
    assert_equal @field_configuration.reload.configurable_type, old_field_configurable_type

    valid_params = {field_configuration: {id: @id, field_name: 'New Name2', configurable_type: new_field_configurable_type}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert_equal result.field_configuration.field_name, 'New Name2'
    assert_equal result.field_configuration.configurable_type, old_field_configurable_type
  end

  test 'Field Configurable ID cannot be updated' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    old_field_configurable_id = @field_configuration.configurable_id
    new_field_configurable_id = 120
    assert_not_equal old_field_configurable_id, new_field_configurable_id

    valid_params = {field_configuration: {id: @id, configurable_id: new_field_configurable_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.failure?
    assert_equal @field_configuration.reload.configurable_id, old_field_configurable_id

    valid_params = {field_configuration: {id: @id, field_name: 'New Name2', configurable_id: new_field_configurable_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert_equal result.field_configuration.field_name, 'New Name2'
    assert_equal result.field_configuration.configurable_id, old_field_configurable_id
  end

  test 'Field Company ID cannot be updated' do
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    old_company_id = @field_configuration.company_id
    new_company_id = 2
    assert_not_equal old_company_id, new_company_id

    valid_params = {field_configuration: {id: @id, company_id: new_company_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.failure?
    assert_equal @field_configuration.reload.company_id, old_company_id

    valid_params = {field_configuration: {id: @id, field_name: 'New Name3', company_id: new_company_id}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert_equal result.field_configuration.field_name, 'New Name3'
    assert_equal result.field_configuration.company_id, old_company_id
  end

  test 'Only company admins and policy admins can update field configurations' do
    # Trying to update for company
    @user.stubs(:admin?).returns(false)

    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    valid_params = {field_configuration: {id: @id, field_name: 'New Test Title'}}
    not_authorized_exception = false
    begin
      CustomField::Configuration::Update.(@user, valid_params)
    rescue NotAuthorizedException
      not_authorized_exception = true
    end
    assert not_authorized_exception


    # Company admin creating a field configuration
    @user.stubs(:admin?).returns(true)
    @user.stubs(:company_admin?).returns(true)
    old_field_name = @field_configuration.field_name
    new_field_name = 'New Test Title'
    assert_not_equal old_field_name, new_field_name

    valid_params = {field_configuration: {id: @id, field_name: new_field_name}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert result.field_configuration.present?
    assert result.field_configuration.id.present?
    assert result.field_configuration.reload.present?
    assert_equal result.field_configuration.reload.field_name, new_field_name
    assert_equal result.field_configuration.field_parent_type_id, FieldParentType.id_for(:report)
    assert_equal result.field_configuration.field_type_id, FieldType.id_for(:number)
    assert @company.field_configurations.with_id(result.field_configuration.id).present?
  end

  test 'Policy admins can update field configurations only for the policy they belong to' do
    # Trying to update for company
    @user.stubs(:admin?).returns(true)
    @user.stubs(:company_admin?).returns(false)
    @user.stubs(:policy_admin?).returns(true)


    valid_params = {field_configuration: {id: @id, field_name: 'new_field_name'}}
    not_authorized_exception = false
    begin
      CustomField::Configuration::Update.(@user, valid_params)
    rescue NotAuthorizedException
      not_authorized_exception = true
    end
    assert not_authorized_exception

    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => @field_configuration))))

    old_field_name = @field_configuration.field_name
    new_field_name = 'New Test Title'
    assert_not_equal old_field_name, new_field_name

    valid_params = {field_configuration: {id: @id, field_name: new_field_name}}
    result = CustomField::Configuration::Update.(@user, valid_params)
    assert result.success?
    assert result.field_configuration.present?
    assert result.field_configuration.id.present?
    assert result.field_configuration.reload.present?
    assert_equal result.field_configuration.reload.field_name, new_field_name
    assert_equal result.field_configuration.field_parent_type_id, FieldParentType.id_for(:report)
    assert_equal result.field_configuration.field_type_id, FieldType.id_for(:number)
    assert @company.field_configurations.with_id(result.field_configuration.id).present?g
  end

end