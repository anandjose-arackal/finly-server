require 'test_helper'

class CreateTimeExpensesTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @receipt_image = File.open("#{Rails.root}/app/assets/images/1363397.png")
    @valid_expense_params = { expense: {time_expense_attributes: {time_object_attributes: {value: '100'}},
                                        note: "Sample note",
                                        category_id: '3',
                                        date: "18-03-2017",
                                        expense_status_id: '1'
                                       },
                              type: '3'
                            }
    @valid_expense_params_with_receipt = { expense: {time_expense_attributes: {time_object_attributes: {value: '100'}},
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
    @admin.stubs(:time_expense_enabled?).returns(true)
    operation = Expense::ExTime::Create.new(@admin, @valid_expense_params)
    assert_difference 'Expense.count', 1 do
      @result = operation.run
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert TimeExpense.exists?(@result.expense.time_expense.id)
    assert_equal 100, @result.expense.time_expense.time_object_value
    assert_equal @admin.id, @result.expense.user_id
    assert_empty @result.expense.receipts
  end

  test "users can create a distance expense with a receipt" do
    @admin.stubs(:time_expense_enabled?).returns(true)
    operation = Expense::ExTime::Create.new(@admin, @valid_expense_params_with_receipt)
    assert_difference 'Expense.count', 1 do
      assert_difference 'Receipt.count', 1 do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert TimeExpense.exists?(@result.expense.time_expense.id)
    assert_equal 100, @result.expense.time_expense.time_object_value
    assert_equal @admin.id, @result.expense.user_id
    assert_not_empty @result.expense.receipts
    assert_equal 1, @result.expense.receipts.count
  end

  test "users can create a distance expense with a receipt id" do
    @admin.stubs(:time_expense_enabled?).returns(true)
    # adding the receipt id to the expense attributes
    @valid_expense_params[:receipt_id] = @receipt.id
    operation = Expense::ExTime::Create.new(@admin, @valid_expense_params)
    assert_difference 'Expense.count', 1 do
      assert_no_difference 'Receipt.count' do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert TimeExpense.exists?(@result.expense.time_expense.id)
    assert_equal 100, @result.expense.time_expense.time_object_value
    assert_equal @admin.id, @result.expense.user_id
    assert_not_empty @result.expense.receipts
    assert_equal 1, @result.expense.receipts.count
    assert_equal @receipt.id, @result.expense.receipts.first.id
  end

  test "users can create an expense from within a report as well" do
    # first without a receipt
    @admin.stubs(:time_expense_enabled?).returns(true)
    # adding report id to the valid expense params
    @valid_expense_params[:expense][:report_id] = @report.id

    operation = Expense::ExTime::Create.new(@admin, @valid_expense_params)
    assert_difference 'Expense.count', 1 do
      assert_difference '@report.expenses.count', 1 do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert TimeExpense.exists?(@result.expense.time_expense.id)
    assert_equal 100, @result.expense.time_expense.time_object_value
    assert_equal @admin.id, @result.expense.user_id
    assert_equal @report.id, @result.expense.report_id

    # now trying with a receipt
    @valid_expense_params_with_receipt[:expense][:report_id] = @report.id
    operation = Expense::ExTime::Create.new(@admin, @valid_expense_params_with_receipt)
    assert_difference 'Expense.count', 1 do
      assert_difference '@report.expenses.count', 1 do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert TimeExpense.exists?(@result.expense.time_expense.id)
    assert_equal 100, @result.expense.time_expense.time_object_value
    assert_equal @admin.id, @result.expense.user_id
    assert_equal @report.id, @result.expense.report_id
    assert_not_empty @result.expense.receipts
    assert_equal 1, @result.expense.receipts.count
  end

end