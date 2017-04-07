require 'test_helper'

class CreatePerDiemExpensesTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @receipt_image = File.open("#{Rails.root}/app/assets/images/1363397.png")
    @per_diem = @company.per_diems.create(name: "Something", rate_attributes: {value: "20", currency_id: 1})
    @valid_expense_params = { expense: {per_diem_expense_attributes: {per_diem_id: @per_diem.id,
                                                                      quantity: "2"
                                                                      },
                                        note: "Sample note",
                                        category_id: '3',
                                        date: "18-03-2017",
                                        expense_status_id: '1'
    },
                              type: '5'
    }
    @valid_expense_params_with_receipt = { expense: {per_diem_expense_attributes: {per_diem_id: @per_diem.id,
                                                                               quantity: "2"
                                                                              },
                                                     note: "Sample note",
                                                     category_id: '3',
                                                     date: "18-03-2017",
                                                     expense_status_id: '1',
                                                     receipts_attributes: {image: @receipt_image}
                                                    },
                                           type: '5'
                                         }
    @receipt = @admin.receipts.create({image: @receipt_image})
    @report = @admin.reports.open.first
  end

  test "users can create per diem expenses without receipt" do
    @admin.stubs(:per_diem_expense_enabled?).returns(true)
    operation = Expense::ExPerDiem::Create.new(@admin, @valid_expense_params)
    assert_difference 'Expense.count', 1 do
      @result = operation.run
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert PerDiemExpense.exists?(@result.expense.per_diem_expense.id)
    assert_equal 2, @result.expense.per_diem_expense.quantity
    assert_equal @per_diem.id, @result.expense.per_diem_expense.per_diem_id
    assert_equal @admin.id, @result.expense.user_id
  end

  test "users can create a per diem expense with receipt" do
    @admin.stubs(:per_diem_expense_enabled?).returns(true)
    operation = Expense::ExPerDiem::Create.new(@admin, @valid_expense_params_with_receipt)
    assert_difference 'Expense.count', 1 do
      assert_difference 'Receipt.count', 1 do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert PerDiemExpense.exists?(@result.expense.per_diem_expense.id)
    assert_equal 2, @result.expense.per_diem_expense.quantity
    assert_equal @per_diem.id, @result.expense.per_diem_expense.per_diem_id
    assert_equal @admin.id, @result.expense.user_id

    assert_not @result.expense.receipts.empty?
    assert_equal 1, @result.expense.receipts.count
  end

  test "users can create per diem expenses with a receipt id" do
    @admin.stubs(:per_diem_expense_enabled?).returns(true)
    @valid_expense_params[:receipt_id] = @receipt.id
    operation = Expense::ExPerDiem::Create.new(@admin, @valid_expense_params)
    assert_difference 'Expense.count', 1 do
      assert_no_difference 'Receipt.count' do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert PerDiemExpense.exists?(@result.expense.per_diem_expense.id)
    assert_equal 2, @result.expense.per_diem_expense.quantity
    assert_equal @per_diem.id, @result.expense.per_diem_expense.per_diem_id
    assert_equal @admin.id, @result.expense.user_id

    assert_not @result.expense.receipts.empty?
    assert_equal @receipt.id, @result.expense.receipts.first.id
    assert_not @receipt.reload.parent.nil?
  end

  test "users can create expenses from within reports as well" do
    # first without a receipt
    @admin.stubs(:per_diem_expense_enabled?).returns(true)
    # adding report id to the valid expense params
    @valid_expense_params[:expense][:report_id] = @report.id

    operation = Expense::ExPerDiem::Create.new(@admin, @valid_expense_params)
    assert_difference 'Expense.count', 1 do
      assert_difference '@report.expenses.count', 1 do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert PerDiemExpense.exists?(@result.expense.per_diem_expense.id)
    assert_equal 2, @result.expense.per_diem_expense.quantity
    assert_equal @per_diem.id, @result.expense.per_diem_expense.per_diem_id
    assert_equal @admin.id, @result.expense.user_id
    assert_equal @report.id, @result.expense.report_id

    # now trying with a receipt
    @valid_expense_params_with_receipt[:expense][:report_id] = @report.id
    operation = Expense::ExPerDiem::Create.new(@admin, @valid_expense_params_with_receipt)
    assert_difference 'Expense.count', 1 do
      assert_difference '@report.expenses.count', 1 do
        @result = operation.run
      end
    end

    assert @result.success?
    assert Expense.exists?(@result.expense.id)
    assert PerDiemExpense.exists?(@result.expense.per_diem_expense.id)
    assert_equal 2, @result.expense.per_diem_expense.quantity
    assert_equal @per_diem.id, @result.expense.per_diem_expense.per_diem_id
    assert_equal @report.id, @result.expense.report_id
    assert_not_empty @result.expense.receipts
    assert_equal 1, @result.expense.receipts.count
  end
end