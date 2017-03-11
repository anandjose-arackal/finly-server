require 'test_helper'

require 'minitest/unit'
require 'mocha/mini_test'

class UpdateTest < ActiveSupport::TestCase

  # def setup
  #   @user = User.first
  #   @user.stubs(:company_admin? => true)
  #   @company = Company.first
  #   @policy = Policy.first
  #   @user_2 = User.second
  #   @field_configuration = FieldConfiguration.new(field_name: 'Old Test Title', field_type_id: 2, mandatory: false,
  #                                                  default_value: 10, field_parent_type_id: FieldParentType.id_for(:report),
  #                                                  configurable_id: @company.id, configurable_type: 'Company')
  #   @field_configuration.save
  #   @id = @field_configuration.id
  # end
  #
  # test 'successful update of field_configuration at a company level' do
  #   valid_params = {field_configuration: {id: 1, field_name: 'New Test Title'}}
  #   result = CustomField::Configuration::Update.(@user, valid_params)
  #   assert result.success?
  #   assert result.field_configuration.present?
  #   assert result.field_configuration.id.present?
  #   assert result.field_configuration.reload.present?
  #   assert_equal result.field_configuration.reload.field_name, 'New Test Title'
  #   assert_equal result.field_configuration.field_parent_type_id, FieldParentType.id_for(:report)
  #   assert @company.field_configurations.with_id(result.field_configuration.id).present?
  # end
  #
  # test 'not wrapping the configuration in field_configuration should fail' do
  #   valid_params = {field_name: 'Test Title User', field_type_id: 1, mandatory: false,
  #                   default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                   configurable_id: @policy.id, configurable_type: 'Policy'}
  #   result = nil
  #   assert_no_difference 'FieldConfiguration.count' do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.failure?
  # end
  #
  # test 'Field name is required to create field configuration' do
  #   valid_params = {field_configuration: {id: 1, field_type_id: 1, mandatory: false,
  #                                         default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_id: @policy.id, configurable_type: 'Policy'}}
  #   result = nil
  #   assert_no_difference 'FieldConfiguration.count' do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.failure?
  # end
  #
  # test 'Field parent type id is required to create field configuration' do
  #   valid_params = {field_configuration: {id: 1, field_type_id: 1,
  #                                         configurable_id: @policy.id, configurable_type: 'Policy'}}
  #   result = nil
  #   assert_no_difference 'FieldConfiguration.count' do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.failure?
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title User', field_type_id: 1, field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_id: @policy.id, configurable_type: 'Policy'}}
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  #   assert result.field_configuration.present?
  #   assert result.field_configuration.id.present?
  #   assert result.field_configuration.reload.present?
  #   assert_equal result.field_configuration.mandatory, false
  #   assert_equal result.field_configuration.reload.field_name, 'Test Title User'
  #   assert @policy.field_configurations.with_id(result.field_configuration.id).present?
  # end
  #
  # test 'Configurable ID required to create field configuration' do
  #   valid_params = {field_configuration: {id: 1, field_name: 'test field', field_type_id: 1, mandatory: false,
  #                                         default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_type: 'Policy'}}
  #   result = nil
  #   assert_no_difference 'FieldConfiguration.count' do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.failure?
  # end
  #
  # test 'Configurable Type required to create field configuration' do
  #   valid_params = {field_configuration: {id: 1, field_name: 'test field', field_type_id: 1, mandatory: false,
  #                                         default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_id: @user_2.id, configurable_type: 'Payment'}}
  #   result = nil
  #   assert_no_difference 'FieldConfiguration.count' do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.failure?
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'test field', field_type_id: 1, mandatory: false,
  #                                         default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_id: @user_2.id, configurable_type: 'User'}}
  #   result = nil
  #   assert_no_difference 'FieldConfiguration.count' do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.failure?
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'test field', field_type_id: 1, mandatory: false,
  #                                         default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_id: @policy.id, configurable_type: 'Policy'}}
  #   result = nil
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'test field', field_type_id: 1, mandatory: false,
  #                                         default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_id: @user_2.id, configurable_type: 'Policy'}}
  #   result = nil
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'test field', field_type_id: 1, mandatory: false,
  #                                         default_value: '100', field_parent_type_id: FieldParentType.id_for(:money_request),
  #                                         configurable_id: @user_2.id, configurable_type: 'Company'}}
  #   result = nil
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  # end
  #
  # test 'When default value is set, a new default value object is created' do
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: FieldType.id_for(:decimal), mandatory: false,
  #                                         default_value: '10.1001', field_parent_type_id: FieldParentType.id_for(:report),
  #                                         configurable_id: @company.id, configurable_type: 'Company'}}
  #   result = nil
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  #   assert result.field_configuration.reload.present?
  #   assert result.field_configuration.default_value.present?
  #   assert result.field_configuration.default_value.kind_of?(FieldDecimal)
  #   assert_equal result.field_configuration.default_value.value_as_decimal, 10.1001
  # end
  #
  # test 'Only company admins and policy admins can create field configurations' do
  #   # Trying to create for company
  #   @user.stubs(:admin?).returns(false)
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: FieldType.id_for(:decimal), mandatory: false,
  #                                         default_value: '10.1001', field_parent_type_id: FieldParentType.id_for(:report),
  #                                         configurable_id: @company.id, configurable_type: 'Company'}}
  #   result = nil
  #   not_authorized_exception = false
  #   assert_no_difference 'FieldConfiguration.count' do
  #     begin
  #       result = CustomField::Configuration::Update.(@user, valid_params)
  #     rescue NotAuthorizedException
  #       not_authorized_exception = true
  #     end
  #   end
  #   assert not_authorized_exception
  #
  #
  #   # Company admin creating a field configuration
  #   @user.stubs(:admin?).returns(true)
  #   @user.stubs(:company_admin?).returns(true)
  #   Policy::Index.stubs(:call => stub(:policies => stub(:with_id => stub(:present? => true))))
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: FieldType.id_for(:decimal), mandatory: false,
  #                                         default_value: '10.1001', field_parent_type_id: FieldParentType.id_for(:report),
  #                                         configurable_id: 1, configurable_type: 'Policy'}}
  #   result = nil
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  #   assert result.field_configuration.reload.present?
  #   assert result.field_configuration.default_value.present?
  #   assert result.field_configuration.default_value.kind_of?(FieldDecimal)
  #   assert_equal result.field_configuration.default_value.value_as_decimal, 10.1001
  # end
  #
  # test 'Policy admins can create field configurations only for the policy they belong to' do
  #   # Trying to create for company
  #   @user.stubs(:admin?).returns(true)
  #   @user.stubs(:company_admin?).returns(false)
  #   @user.stubs(:policy_admin?).returns(true)
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: FieldType.id_for(:decimal), mandatory: false,
  #                                         default_value: '10.1001', field_parent_type_id: FieldParentType.id_for(:report),
  #                                         configurable_id: @company.id, configurable_type: 'Company'}}
  #   result = nil
  #   not_authorized_exception = false
  #   assert_no_difference 'FieldConfiguration.count' do
  #     begin
  #       result = CustomField::Configuration::Update.(@user, valid_params)
  #     rescue NotAuthorizedException
  #       not_authorized_exception = true
  #     end
  #   end
  #   assert not_authorized_exception
  #
  #   # Trying to create for policy for which the user is not an admin
  #   Policy::Index.stubs(:call => stub(:policies => stub(:with_id => stub(:present? => false))))
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: FieldType.id_for(:decimal), mandatory: false,
  #                                         default_value: '10.1001', field_parent_type_id: FieldParentType.id_for(:report),
  #                                         configurable_id: 1, configurable_type: 'Policy'}}
  #   result = nil
  #   not_authorized_exception = false
  #   assert_no_difference 'FieldConfiguration.count' do
  #     begin
  #       result = CustomField::Configuration::Update.(@user, valid_params)
  #     rescue NotAuthorizedException
  #       not_authorized_exception = true
  #     end
  #   end
  #   assert not_authorized_exception
  #
  #   Policy::Index.stubs(:call => stub(:policies => stub(:with_id => stub(:present? => true))))
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: FieldType.id_for(:decimal), mandatory: false,
  #                                         default_value: '10.1001', field_parent_type_id: FieldParentType.id_for(:report),
  #                                         configurable_id: 1, configurable_type: 'Policy'}}
  #   result = nil
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  #   assert result.field_configuration.reload.present?
  #   assert result.field_configuration.default_value.present?
  #   assert result.field_configuration.default_value.kind_of?(FieldDecimal)
  #   assert_equal result.field_configuration.default_value.value_as_decimal, 10.1001
  # end
  #
  # test 'field configuration can only be created at organisation level for expenses' do
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: 2, mandatory: false,
  #                                         default_value: 10, field_parent_type_id: FieldParentType.id_for(:expense),
  #                                         configurable_id: 1, configurable_type: 'Policy'}}
  #   result = nil
  #   assert_no_difference 'FieldConfiguration.count' do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert_not result.success?
  #
  #   valid_params = {field_configuration: {id: 1, field_name: 'Test Title', field_type_id: 2, mandatory: false,
  #                                         default_value: 10, field_parent_type_id: FieldParentType.id_for(:expense),
  #                                         configurable_id: @company.id, configurable_type: 'Company'}}
  #   result = nil
  #   assert_difference 'FieldConfiguration.count', 1 do
  #     result = CustomField::Configuration::Update.(@user, valid_params)
  #   end
  #   assert result.success?
  #   assert result.field_configuration.present?
  #   assert result.field_configuration.id.present?
  #   assert result.field_configuration.reload.present?
  #   assert_equal result.field_configuration.reload.field_name, 'Test Title'
  #   assert @company.field_configurations.with_id(result.field_configuration.id).present?
  # end

end