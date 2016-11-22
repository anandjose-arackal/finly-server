require 'test_helper'

class DestroyTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @employee = users(:employee)
    @other_admin = users(:other_company_admin)
    @category_params = {category: {name: "Testing..."}}
    @category = @company.categories.first
  end

  test "admins can destroy a category for the company" do
    destroy_op = Company::Configuration::Category::Destroy.new(@admin, id: @category.id)
    assert_difference '@company.categories.active.count', -1 do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not @category.reload.active
  end

  test "destroying a category only 'soft-deletes' it" do
    destroy_op = Company::Configuration::Category::Destroy.new(@admin, id: @category.id)
    assert_no_difference '@company.categories.count' do
      @result = destroy_op.run
    end
    assert @result.success?
    assert_not @category.reload.active
    assert Category.exists?(@category.id)
  end

  test "non admins cannot destroy a category for the company" do
    # finance manager trying to destroy a category
    destroy_op = Company::Configuration::Category::Destroy.new(@finance_manager, id: @category.id)
    assert_no_difference '@company.categories.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued

    # manager trying the same shit
    destroy_op = Company::Configuration::Category::Destroy.new(@manager, id: @category.id)
    assert_no_difference '@company.categories.count' do
      begin
        @result = destroy_op.run
      rescue
        @rescued = true
      end
    end
    assert @rescued
  end

  test "cannot destroy 'Personal' or 'Other' categories" do
    # trying to destroy 'Other' category
    @category = @company.categories.find_by(name: 'Other')

    destroy_op = Company::Configuration::Category::Destroy.new(@admin, id: @category.id)
    assert_no_difference '@company.categories.active.count' do
      @result = destroy_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Cannot destroy 'Other' or 'Personal' categories", @result.messages[:error].first

    # trying to destroy 'Personal' category
    @category = @company.categories.find_by(name: 'Personal')

    destroy_op = Company::Configuration::Category::Destroy.new(@admin, id: @category.id)
    assert_no_difference '@company.categories.active.count' do
      @result = destroy_op.run
    end
    assert_not @result.success?
    assert_not @result.messages[:error].empty?
    assert_equal "Cannot destroy 'Other' or 'Personal' categories", @result.messages[:error].first
  end

  test "" do

  end

end