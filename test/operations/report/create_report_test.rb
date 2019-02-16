# require 'test_helper'
#
# class CreateTest < ActiveSupport::TestCase
#
#
#   def setup
#     @user = User.first
#     @expense_ids = @user.expenses.unreported.limit(5).pluck(:id)
#     @other_ids = User.second.expenses.unreported.limit(5).pluck(:id)
#   end
#
#   test 'creating a report with valid parameters' do
#     assert_difference '@user.reports.count', 1 do
#       @report = Reports::Create.new(@user, name: "Test name").run
#       assert_equal 1, @report.tracks.count
#       assert_equal "Test name", @report.name
#       assert_equal 0, @report.expenses.count
#     end
#
#     # creating a report with expenses
#     assert_difference '@user.reports.count', 1 do
#       @report = Reports::Create.new(@user, {expense_ids: @expense_ids}).run
#       assert_equal 1, @report.tracks.count
#       assert @report.name
#       assert_not @report.expenses.empty?
#     end
#
#     # create a report with someone else's expenses
#     assert_difference '@user.reports.count', 1 do
#       @report = Reports::Create.new(@user, {expense_ids: @other_ids}).run
#       # assert that an empty report got created and it has no expenses
#       assert @report
#       assert @report.expenses.empty?
#     end
#   end
# end