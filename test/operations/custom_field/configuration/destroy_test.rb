require 'test_helper'

require 'minitest/unit'
require 'mocha/mini_test'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @company = Company.first
  end

  test 'Successful destroy' do
    @user.stubs(:company_admin? => true)
    field_configuration = FieldConfiguration.new
    field_configuration.expects(:destroy).returns(true)
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => field_configuration))))

    result = CustomField::Configuration::Destroy.(@user, field_configuration_id: 1)
    assert result.success?
  end

  test 'Only admins and policy admins can destroy field_configurations' do
    @user.stubs(:company_admin? => false, :policy_admin? => false)
    field_configuration = FieldConfiguration.new
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => field_configuration))))

    unauthorized = false
    begin
      CustomField::Configuration::Destroy.(@user, field_configuration_id: 1)
    rescue NotAuthorizedException
      unauthorized = true
    end
    assert unauthorized
  end

end