require 'test_helper'

class CreatePerDiemExpensesTest < ActiveSupport::TestCase

  def setup
    @company = Company.first
    @admin = User.first
    @finance_manager = User.second
    @manager = User.third
    @receipt_image = File.open("#{Rails.root}/app/assets/images/1363397.png")
    @valid_expense_params = { expense: {per_diem_expense_attributes: {time_object_attributes: {value: '100'}},
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

  test "users can create per diem expenses without receipt" do

  end
end