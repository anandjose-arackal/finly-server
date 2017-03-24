require 'test_helper'

class CreatePerDiemExpensesTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @receipt_image = File.open("#{Rails.root}/app/assets/images/1363397.png")
    @per_diem = @company.per_diems.create(rate_attributes: {value: "20", currency_id: 1})
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
    assert PerDiemExpense.exists?(@result.expense.distance_expense.id)
    assert_equal 2, @result.expense.per_diem_expense.quantity
    assert_equal @per_diem.id, @result.expense.per_diem_expense.per_diem_id
    assert_equal @admin.id, @result.expense.user_id
  end
end