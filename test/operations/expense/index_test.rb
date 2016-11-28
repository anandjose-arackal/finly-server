# shit, ignore

require 'test_helper'

class IndexTest < ActiveSupport::TestCase

  def setup
    @admin = users(:admin)
    @manager = users(:manager)
    @employee = users(:employee)
    @company = Company.first
  end

  test "returns user's personal expenses" do
    expenses_from_db = @employee.expenses.unreported
    @result = Expense::Index.(@employee, page: 1)
    db_ids = expenses_from_db.pluck(:id)
    op_ids = @result.unreported_expenses.pluck(:id)
    assert_equal [], db_ids - op_ids
  end

  # test "for manager, returns the expenses of everyone in the manager's team" do
  #   user_ids = User.where(company_id: @admin.company.id).pluck(:id)
  #   expenses_from_db = Expense.where(user_id: user_ids).submitted
  #   expenses_from_op = Expense::Index.(@admin, role_id: 1)
  #   assert_equal expenses_from_db.count, expenses_from_op.count
  # end
  #
  # test "for finance manager, returns the expenses of everyone in finance manager's team" do
  #
  # end
  #
  test "for admin, returns the expenses for everyone in admin's team i.e. company" do
    user_ids = User.where(company_id: @company.id)
    db_expense_ids = Expense.only_manual_expenses.admin_viewable.where(user_id: user_ids).pluck(:id)
    db_expense_ids += Expense.only_card_expenses.where(user_id: user_ids).pluck(:id)

    @result = Expense::Index.(@admin, view: 'admin')
    op_expense_ids = @result.expenses.pluck(:id)

    assert_equal [], db_expense_ids - op_expense_ids
  end


end