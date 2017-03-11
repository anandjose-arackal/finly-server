require 'test_helper'

require 'minitest/unit'
require 'mocha/mini_test'

class ShowTest < ActiveSupport::TestCase

  def setup
    @user = User.first
    @company = Company.first
  end

  test 'Successful show' do
    @user.stubs(:company_admin? => true)
    field_configuration = FieldConfiguration.new
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => field_configuration))))

    result = CustomField::Configuration::Show.(@user, field_configuration_id: 1)
    assert result.success?
    assert_equal result.field_configuration, field_configuration
  end

  test 'Only admins and policy admins can view field_configurations' do
    @user.stubs(:company_admin? => false, :policy_admin? => false)
    field_configuration = FieldConfiguration.new
    CustomField::Configuration::Index.stubs(:call => stub(:field_configurations => stub(:with_id => stub(:first => field_configuration))))

    unauthorized = false
    begin
      CustomField::Configuration::Show.(@user, field_configuration_id: 1)
    rescue NotAuthorizedException
      unauthorized = true
    end
    assert unauthorized
  end

end