require 'test_helper'

class CreateDistanceExpensesTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @receipt_image = File.open("#{Rails.root}/app/assets/images/1363397.png")
    @valid_expense_params = { expense: {distance_expense_attributes: {distance_attributes: {value: '100'}},
                                         note: "Sample note",
                                         category_id: '3',
                                         date: "18-03-2017",
                                         expense_status_id: '1'
                                        },
                              type: '3'
                            }
    @valid_expense_params_with_receipt = { expense: {distance_expense_attributes: {distance_attributes: {value: '100'}},
                                                     note: "Sample note",
                                                     category_id: '3',
                                                     date: "18-03-2017",
                                                     expense_status_id: '1',
                                                     receipts_attributes: {image: @receipt_image}
                                                    },
                                           type: '3'
                                         }
    @receipt = @admin.receipts.create({image: @receipt_image})
    @report = @admin.reports.open.first
  end

  test "users can create distance expenses without receipt" do
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

  test "admin can create a distance expense with a receipt" do
    @admin.stubs(:distance_expense_enabled?).returns(true)
    operation = Expense::ExDistance::Create.new(@admin, @valid_expense_params_with_receipt)
    assert_difference 'Expense.count', 1 do
      assert_difference 'Receipt.count', 1 do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert DistanceExpense.exists?(@result.expense.distance_expense.id)
    assert_equal 100, @result.expense.distance_expense.distance_value
    assert_equal @admin.id, @result.expense.user_id
    assert_equal 1, @result.expense.receipts.count
  end

  test "admin can create a distance expense with a receipt id" do

  end

end