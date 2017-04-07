require 'test_helper'

require 'minitest/unit'
require 'mocha/mini_test'

class IndexTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @company = Company.first
    @policies = Policy.all
  end

  test 'successful test of custom_field configuration index as company admin' do
    @user.stubs(:company_admin? => true)
    field_1 = FieldConfiguration.new
    field_1.stubs(:field_name).returns('company name 1')
    field_2 = FieldConfiguration.new
    field_2.stubs(:field_name).returns('company name 2')
    Company.any_instance.stubs(:field_configurations => [field_1, field_2])

    result = CustomField::Configuration::Index.(@user, for_company: true)
    assert result.success?
    assert_equal result.field_configurations.count, 2
    assert_equal result.field_configurations.first.field_name, 'company name 1'
    assert_equal result.field_configurations.second.field_name, 'company name 2'
  end

  test 'successful test of custom_field configuration index as policy admin' do
    Policy::Index.stubs(:call => stub(:policies => stub(:with_id => stub(:first => @policies.first))))
    @user.stubs(:company_admin? => false, :policy_admin? => true)
    field_1 = FieldConfiguration.new
    field_1.stubs(:field_name).returns('policy name 1')
    field_2 = FieldConfiguration.new
    field_2.stubs(:field_name).returns('policy name 2')
    Policy.any_instance.stubs(:field_configurations => [field_1, field_2])

    result = CustomField::Configuration::Index.(@user, for_policy: true, policy_id: 1)
    assert result.success?
    assert_equal result.field_configurations.count, 2
    assert_equal result.field_configurations.first.field_name, 'policy name 1'
    assert_equal result.field_configurations.second.field_name, 'policy name 2'
  end

  test 'user and params are required for retrieving configuration index' do
    @user.stubs(:company_admin? => true)

    result = CustomField::Configuration::Index.(@user, nil)
    assert result.failure?
    unauthorized = false
    begin
      result = CustomField::Configuration::Index.(nil, for_company: true)
    rescue NotAuthorizedException
      unauthorized = true
    end
    assert unauthorized
  end

  test 'policy admins can retrieve configuration index by providing for_policy and policy_id' do
    @user.stubs(:company_admin? => false, :policy_admin? => true)

    unauthorized = false
    begin
      CustomField::Configuration::Index.(@user, for_company: true)
    rescue NotAuthorizedException
      unauthorized = true
    end
    assert unauthorized

    @user.stubs(:company_admin? => false, :policy_admin? => true)

    unauthorized = false
    begin
      CustomField::Configuration::Index.(@user, for_policy: true)
    rescue NotAuthorizedException
      unauthorized = true
    end
    assert unauthorized

    unauthorized = false
    begin
      CustomField::Configuration::Index.(@user, policy_id: 1)
    rescue NotAuthorizedException
      unauthorized = true
    end
    assert unauthorized
  end

end