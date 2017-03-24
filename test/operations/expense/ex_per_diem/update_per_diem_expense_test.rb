require 'test_helper'

class UpdatePerDiemExpenseTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @receipt_image = File.open("#{Rails.root}/app/assets/images/1363397.png")
    @per_diem = @company.per_diems.create(name: "Something", rate_attributes: {value: "20", currency_id: 1})
    @valid_expense_params = { expense: {per_diem_expense_attributes: {quantity: "20", per_diem_id: @per_diem.id},
                                        note: "Sample note",
                                        category_id: '3',
                                        date: "18-03-2017",
                                        expense_status_id: '1'
                                       },
                              type: '3'
                            }
    @valid_expense_params_with_receipt = { expense: {per_diem_expense_attributes: {quantity: "20", per_diem_id: @per_diem.id},
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

    # sample time expense to update
    @per_diem_expense = Expense::ExPerDiem::Create.(@admin, @valid_expense_params).expense
    @valid_expense_params[:id] = @per_diem_expense.id
  end

  test "users can update a particular time expense" do

    # changing the params of the expense to new ones
    @valid_expense_params[:expense][:time_expense_attributes][:time_object_attributes][:value] = "50"
    @valid_expense_params[:expense][:note] = "Something else"
    @valid_expense_params[:expense][:date] = "21-03-2017"
    operation = Expense::ExTime::Update.new(@admin, @valid_expense_params)

    assert_no_difference 'Expense.count' do
      @result = operation.run
    end

    assert_equal "Something else", @result.expense.note
    assert_equal 50, @result.expense.time_value
    assert_equal Date.parse("21-03-2017"), @result.expense.date
  end

  test "users can attach a new receipt to the expense" do
    assert_empty @time_expense.receipts

    @valid_expense_params[:expense][:receipts_attributes] = {image: @receipt_image}

    operation = Expense::ExTime::Update.new(@admin, @valid_expense_params)
    assert_no_difference 'Expense.count' do
      assert_difference 'Receipt.count', 1 do
        @result = operation.run
      end
    end

    assert_equal 1, @time_expense.reload.receipts.count
    assert_equal "1363397.png", @time_expense.reload.receipts.first.image.original_filename
  end

  test "users can attach an existing receipt to the expense" do
    assert_empty @time_expense.receipts

    @valid_expense_params[:receipt_id] = @receipt.id

    operation = Expense::ExTime::Update.new(@admin, @valid_expense_params)
    assert_no_difference 'Expense.count' do
      assert_difference '@time_expense.receipts.count', 1 do
        @result = operation.run
      end
    end

    assert_equal 1, @time_expense.reload.receipts.count
    assert_equal "1363397.png", @time_expense.reload.receipts.first.image.original_filename
    assert_equal @receipt.id, @time_expense.receipts.first.id
  end

  test "updating an expense in a report generates the requisite comments" do

  end

  test "updating an expense in a report that is not editable" do

  end
end