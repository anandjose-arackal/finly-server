require 'test_helper'

class CreateCategoryTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = users(:admin)
    @manager = users(:manager)
    @finance_manager = users(:finance_manager)
    @employee = users(:employee)
    @other_admin = users(:other_company_admin)
    @category_params = {category: {name: "Testing..."}}
  end

  test "company admins can create new categories" do
    create_category_op = Company::Configuration::Category::Create.new(@admin, @category_params)
    assert_difference '@company.categories.count', 1 do
      @result = create_category_op.run
    end
    assert @result.success?
    assert_equal "Testing...", @result.categories.last.name
  end

  test "non company admins cannot create new categories" do
    create_category_op = Company::Configuration::Category::Create.new(@manager, @category_params)
    assert_no_difference '@company.categories.count' do
      begin
        @result = create_category_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued

    # finance manager trying the same shit
    create_category_op = Company::Configuration::Category::Create.new(@manager, @category_params)
    assert_no_difference '@company.categories.count' do
      begin
        @result = create_category_op.run
      rescue NotAuthorizedException
        @rescued = true
      end
    end
    assert @rescued
  end


  test "cannot create two categories with the same name - instead it just activates the existing category with the same name" do
    Company::Configuration::Category::Create.(@admin, @category_params)

    # trying to create another category with the same name - shouldn't change the number of categories
    create_category_op = Company::Configuration::Category::Create.new(@admin, @category_params)
    assert_no_difference '@company.categories.count' do
      @result = create_category_op.run
    end
    assert @result.success?
    assert @company.categories.last.active
    assert_equal "Testing...", @company.categories.last.name

    # deactivating the existing category so that it can be activated now
    @category = @company.categories.last
    @category.update_attributes(active: false)
    assert_not @category.reload.active

    create_category_op = Company::Configuration::Category::Create.new(@admin, @category_params)
    assert_no_difference '@company.categories.count' do
      @result = create_category_op.run
    end
    assert @result.success?
    assert @category.reload.active
  end

end