# shit, ignore

require 'test_helper'

class IndexTest < ActiveSupport::TestCase

  def setup
    @admin = User.first
    @manager = User.find_by(email: 'manager0@finlytest.io')
    @user = User.find_by(email: 'user0@finlytest.io')
  end

  test "returns user's personal expenses" do
    expenses_from_db = @user.expenses.unreported
    expenses_from_op = Expense::Index.(@user, role_id: 4)
    assert_equal expenses_from_db.count, expenses_from_op.count
  end

  test "for manager, returns the expenses of everyone in the manager's team" do
    user_ids = User.where(company_id: @admin.company.id).pluck(:id)
    expenses_from_db = Expense.where(user_id: user_ids).submitted
    expenses_from_op = Expense::Index.(@admin, role_id: 1)
    assert_equal expenses_from_db.count, expenses_from_op.count
  end

  test "for finance manager, returns the expenses of everyone in finance manager's team" do

  end

  test "for admin, returns the expenses for everyone in admin's team i.e. company" do

  end


end