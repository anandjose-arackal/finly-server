require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @category = @admin.company.categories.first
  end

  test 'Require a valid Category ID to be passed to destroy a category' do
    response = Company::Configuration::Category::Destroy.(@admin)
    assert response.failure?
  end

  test 'Cannot destroy a category of different company' do
    id = Company.second.categories.first.id
    assert_not_equal @admin.company.id, Company.second.id
    response = Company::Configuration::Category::Destroy.(@admin, id: id)
    assert response.failure?
  end

  test 'Only company admins can destroy category' do
    rescued = false
    begin
      Company::Configuration::Category::Destroy.(User.with_company_id(@admin.company_id).last, id: @category.id)
    rescue NotAuthorizedException
      rescued = true
    end
    assert rescued
  end

  test "Cannot destroy 'Personal' and 'Other' categories" do
    personal_category = @admin.company.categories.with_name('Personal').first
    assert personal_category.present?
    response = Company::Configuration::Category::Destroy.(@admin, id: personal_category.id)
    assert response.success?
    assert personal_category.reload.active

    personal_category = @admin.company.categories.with_name('Other').first
    assert personal_category.present?
    response = Company::Configuration::Category::Destroy.(@admin, id: personal_category.id)
    assert response.success?
    assert personal_category.reload.active
  end

  test 'Destroying a category should mark the category as active=false instead of destroying the category' do
    assert @category.present?
    response = Company::Configuration::Category::Destroy.(@admin, id: @category.id)
    assert response.success?
    assert_not @category.reload.active
  end

  test 'Valid Destroy' do
    assert @category.present?
    response = Company::Configuration::Category::Destroy.(@admin, id: @category.id)
    assert response.success?
    assert_not @category.reload.active
  end

end