require 'test_helper'

class CreatePerDiemTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third

    @valid_per_diem_params = {per_diem: {name: "Something",
                                         rate_attributes: {value: "500",
                                                           currency_id: 1}

                                        }
                             }
    @invalid_per_diem_params = {per_diem: {name: "",
                                           rate_attributes: {value: "500",
                                                           currency_id: 1}

                                          }
                               }
  end

  test "company admins can create per diem expenses" do
    # mocking the fact that this user is the admin
    @admin.stubs(:company_admin?).returns(true)
    operation = Company::Configuration::ExpenseTypes::PerDiem::Create.new(@admin, @valid_per_diem_params)
    assert_difference '@company.per_diems.count', 1 do
      @result = operation.run
    end

    assert_equal true, @result.success?
    assert_equal 500, @result.per_diem.rule_value
    assert_equal "Something", @result.per_diem.name
  end
end