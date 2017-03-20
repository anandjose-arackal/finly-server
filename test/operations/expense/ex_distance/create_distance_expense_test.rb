require 'test_helper'

class CreateDistanceExpenseTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @valid_expense_params = { expense: {distance_expense_attributes: {distance_attributes: {value: '100'}},
                                         note: "Sample note",
                                         category_id: '3',
                                         date: "18-03-2017",
                                         expense_status_id: '1'
                                        },
                              type: '3'
                            }
  end

  test "users can create distance expenses" do
    @admin.stubs(:distance_expense_enabled?).returns(true)
    operation = Expense::ExDistance::Create.new(@admin, @valid_expense_params)
    assert_difference 'Expense.count', 1 do
      @result = operation.run
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert DistanceExpense.exists?(@result.expense.distance_expense.id)
    assert_equal 100, @result.expense.distance_expense.distance_value
    assert_equal @admin.id, @result.expense.user_id
  end
end